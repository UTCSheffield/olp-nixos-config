import { logger } from "../../lib/logger.js";

export default function updateError(_val: string, id: number) {
    // Log that the update failed, We want to flash this somewhere eventually
    logger.error(`[${id}] update failed`);
    return {
        type: 'aknowleged',
        value: null
    };
}