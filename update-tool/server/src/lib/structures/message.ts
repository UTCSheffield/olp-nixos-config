import { Piece } from "@sapphire/pieces";

export class Message<Options extends Message.Options = Message.Options> extends Piece<Options, 'messages'> {
    public readonly type: string;

    public constructor(context: Message.LoaderContext, options: Options) {
        super(context, options);
        this.type = options.type;
    }
    // Our run method is empty, as this is just a placeholder so we can call it from any class that extends it.
    public run(_val: any, _id: number) {};
}

export interface MessageOptions extends Piece.Options {
    type: string;
};

export namespace Message {
    export type Options = MessageOptions;
    export type LoaderContext = Piece.LoaderContext<'messages'>
}