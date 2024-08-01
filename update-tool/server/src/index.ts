import WebSocket from "ws";
import { logger } from "./lib/logger";
import { container } from "@sapphire/pieces";
import { MessageStore } from "./lib/structures/messageStore";


// A bunch of container sets, TODO: Move this to lib/setup.ts
container.logger = logger;

/*
  We dynamically load our protocool responders from the messages store (the messages folder in this directory)
  This allows us to segregate our code into smaller, more manageable chunks without 1 long switch, making it more readable.
*/
container.stores.register(new MessageStore());
console.log(container.stores.get('messages').paths);
logger.info(`Loaded ${container.stores.get('messages').size} message responders from store.`);
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
    type: 'configVersion',
    id: sockets.length
  })); // We want to know the config version of the client so we can determine if an Upgrade is needed

  
  // When we receive a message from a client, Throw it into a big switch statement (Easier to maintain system coming soon)
  socket.on('message', function(msg) {
    logger.info(`Received message from client`);
    const parsedMsg: IWebsocketEventStructure = JSON.parse(msg.toString());
    const messageResponder = container.stores.get('messages').get(parsedMsg.type);
    if (!messageResponder) {
      logger.error(`No message responder found for type ${parsedMsg.type}`);
      return;
    }
    messageResponder.run(parsedMsg.value, parsedMsg.id);
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

declare module '@sapphire/pieces' {

  interface Container {
    logger: typeof logger;
  }

  interface StoreRegistryEntries {
		messages: MessageStore;
	}
}