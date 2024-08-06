import { container } from "../../lib/container.js";
import { logger } from "../../lib/logger.js";

export default async function currentVersion(val: string, id: number) {
    if (container.latestGitCommitHash !== val) {
        logger.debug(`[${id}] update to ${container.latestGitCommitHash} available`);
        return {
            type: 'updateAvailable',
            value: container.latestGitCommitHash
        }
    } else {
        logger.debug(`[${id}] No update available`);
        return {
            type: 'updateNotAvailable',
            value: container.latestGitCommitHash
        };
    }
};