import { container } from "../../lib/container.js";
import { logger } from "../../lib/logger.js";

export default async function currentVersion(val: string, id: number) {
    console.log(container.latestGitCommitHash)
    if (container.latestGitCommitHash !== val) {
        logger.debug(`[${id}] update to ${container.latestGitCommitHash} available`);
        return {
            type: 'updateAvaliable',
            value: container.latestGitCommitHash
        }
    } else {
        logger.debug(`[${id}] No update available`);
        return {
            type: 'updateNotAvaliable',
            value: container.latestGitCommitHash
        };
    }
};
