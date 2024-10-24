// Our container, Defined once and then we just add different properties to it
export const container: Container = {
    latestGitCommitHash: ""
};

interface Container {
    latestGitCommitHash: string;
}