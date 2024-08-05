import * as fs from 'fs/promises';

export async function fetchResponses() {
    const baseDir = `${process.cwd()}/dist/responses`;
    // We only want to load .js files from the responses directory. Not anything else that TS generates for debugging
    const files = (await fs.readdir(baseDir)).filter(f => f.endsWith('.js'));
    // We will store the responses in a Map, with the filename as the key, and the response function to call as the value, Is a map to remove duplicates
    const responses = new Map<string, ResponseFunction>();
    for (const file of files) {
        const response = await import(`file://${baseDir}/${file}`); // We append file:// to the path so that Node's ESM loader can successfully load the file
        responses.set(file.replace('.js', ''), response.default); // We store the object from each response file in the map as a typed string
    }
    return responses;
}


/* Response functions */
type ResponseFunction = () => Promise<string>;