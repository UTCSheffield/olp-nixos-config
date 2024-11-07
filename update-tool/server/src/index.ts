import { WebSocketServer, WebSocket } from "ws";
import { logger } from "./lib/logger.js";
import "./lib/container.js";
import { fetchResponses } from "./lib/responseLoader.js";
import { createColors } from "colorette";
import http, { RequestListener } from "http";
import { Webhooks } from "@octokit/webhooks";

createColors(); // This is used to color the console output. Makes it easier to read.

const avaliableResponses = await fetchResponses();
logger.info(`Loaded ${avaliableResponses.size} responses`);
/*
    This is where we start the WebSocket server.
    - The websocket is used for communication with clients
*/
const server = new WebSocketServer({
  port: 8080
});

server.on('listening', () => {
    logger.info('WebSocket server started on port 8080');
});

let sockets: WebSocket[] = [];
server.on('connection', function(socket) {
  sockets.push(socket);
  const id = sockets.length;
  logger.info(`New connection. Total connections: ${sockets.length}`);
  socket.send(JSON.stringify({
    type: 'configVersion',
    id: id
  })); // We want to know the config version of the client so we can determine if an Upgrade is needed
  
  // Start a cron to issue a ping every 5 seconds to ensure the connection is still alive
  setInterval(() => {
    logger.debug(`Issuing ping to client ${id}`);
    try {
      socket.ping();
    } catch (e) {
      logger.error(`Failed to issue ping to client ${id}`);
      socket.terminate();
      sockets = sockets.filter(s => s !== socket);
    }
  }, 5000);

  // When we receive a message from a client, Throw it into a big switch statement (Easier to maintain system coming soon)
  socket.on('message', async function(msg) {
    const parsedMsg: IWebsocketEventStructure = JSON.parse(msg.toString());
    logger.info(`[${parsedMsg.id}] Received message from client`);
    const selectedResponse = avaliableResponses.get(parsedMsg.type);
    if (!selectedResponse) {
      logger.error(`No message responder found for type ${parsedMsg.type}`);
      return;
    } else {
      logger.debug(`[${parsedMsg.id}] Selected response for type ${parsedMsg.type}`);
      // We call the selected response function and send the result back to the requesting client
      const response = await selectedResponse(parsedMsg.value, parsedMsg.id);
      socket.send(JSON.stringify({
        id: parsedMsg.id,
        type: response.type,
        value: response.value
      }));
    }
  });
  // When a socket closes, or disconnects, remove it from the array.
  socket.on('close', function() {
    sockets = sockets.filter(s => s !== socket);
    logger.info(`Connection closed. Total connections: ${sockets.length}`);
  });
});

interface IWebsocketEventStructure {
    type: string;
    id: number;
    value: any;
}

// Simple HTTP server for github push webhooks
const requestListener: RequestListener = async function async (req, _res) {
  if (req.headers["content-type"] == "application/json" && req.method == "POST") {
    let body = "";
    let continueProcess = false;

    req.on('data', chunk => {
      body += chunk.toString();
    });
    req.on("end", () => {
      continueProcess = true; 
    })
    while (continueProcess == false) {}
    // If the request type is JSON, then check the secret
    const webhooks = new Webhooks({
      secret: String(process.env.WEBHOOK_SECRET),
    });
    const signature = String(req.headers["x-hub-signature-256"]);
    if (!(await webhooks.verify(body, signature))) {
      return;
    }
    sockets.forEach((socket) => {
      socket.send(JSON.stringify(
        {
          type: 'updateAvaliable',
          value: "force"
        }
      ))
    })
  }
};

const httpServer = http.createServer(requestListener);
httpServer.listen(3000, "0.0.0.0", () => {
    logger.info(`WebServer is running on http://0.0.0.0:3000`);
});