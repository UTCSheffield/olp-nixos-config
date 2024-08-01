import WebSocket from "ws";
import { logger } from "./lib/logger";

/*
    This is where we start the WebSocket server.
    - The websocket is used for communication with clients
*/
const server = new WebSocket.Server({
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
    type: 'configVersion'
  })); // We want to know the config version of the client so we can determine if an Upgrade is needed

  
  // When we receive a message from a client, Throw it into a big switch statement (Easier to maintain system coming soon)
  socket.on('message', function(msg) {
    logger.info(`Received message from client`);
    const parsedMsg: IWebsocketEventStructure = JSON.parse(msg.toString());
    switch(parsedMsg.type) {
        case 'currentVersion':
            logger.info(`Client is running version ${parsedMsg.value}`);
            break;
        default:
            logger.error(`Unknown message type: ${parsedMsg.type} from Client`);
            socket.send(JSON.stringify({type: 'error', value: 'Unknown message type'}));
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
    value: any;
}