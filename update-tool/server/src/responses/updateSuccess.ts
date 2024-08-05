import { logger } from "../lib/logger.js";

export default function updateSuccess(_val: string, id: number) {
    // Log that the update was successful, We want to display this somewhere eventually
    logger.info(`[${id}] update successful`);
    return {
        type: 'aknowleged',
        value: null
    };
}