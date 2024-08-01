import { ApplyOptions } from "@sapphire/decorators";
import { Message } from "../lib/structures/message";


@ApplyOptions<Message.Options>({
    type: 'currentVersion'
})
export class currentVersionMessage extends Message {
    public override run(value: any, id: number) {
        this.container.logger.info(`Client ${id} is running version ${value}`);
    }
}