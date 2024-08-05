import { WebSocketServer, WebSocket } from "ws";
import { logger } from "./lib/logger.js";
import { fetchResponses } from "./lib/responseLoader.js";
import { createColors } from "colorette";

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
  logger.info(`New connection. Total connections: ${sockets.length}`);
  socket.send(JSON.stringify({
    type: 'configVersion',
    id: sockets.length
  })); // We want to know the config version of the client so we can determine if an Upgrade is needed

  
  // When we receive a message from a client, Throw it into a big switch statement (Easier to maintain system coming soon)
  socket.on('message', async function(msg) {
    const parsedMsg: IWebsocketEventStructure = JSON.parse(msg.toString());
    logger.info(`[${parsedMsg.id}] Received message from client`);
    const selectedResponse = avaliableResponses.get(parsedMsg.type);
    if (!selectedResponse) {
      logger.error(`No message responder found for type ${parsedMsg.type}`);
      return;
    } else {
      logger.info(`[${parsedMsg.id}] Selected response for type ${parsedMsg.type}`);
      // We call the selected response function and send the result back to the requesting client
      const response = await selectedResponse();
      socket.send(JSON.stringify({
        id: parsedMsg.id,
        value: response
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