import { logger } from "../../lib/logger.js";

export default function updateAknowleged(_val: string, id: number) {
    // Just log that the update was acknowledged. We want to update this in the WebUI when that is built
    logger.info(`[${id}] acknoledged update`);
    return {
        type: 'acknowledged',
        value: null
    };
}