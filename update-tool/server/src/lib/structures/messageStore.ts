import { Store } from "@sapphire/pieces";
import { Message } from "./message";
import { MessageLoaderStrategy } from "./messageLoaderStratergy";

export class MessageStore extends Store<Message, 'messages'> {
    constructor() {
        super(Message, { name: 'messages', strategy: new MessageLoaderStrategy() });
    }
}