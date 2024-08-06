import * as fs from 'fs/promises';

export async function fetchResponses() {
    const baseDir = `${process.cwd()}/dist/responses`;
    // We only want to load .js files from the responses directory. Not anything else that TS generates for debugging
    const files = (await fs.readdir(baseDir, {
        withFileTypes: true
    })).filter(f => f.name.endsWith('.js')|| f.isDirectory());
    // We will store the responses in a Map, with the filename as the key, and the response function to call as the value, Is a map to remove duplicates
    const responses = new Map<string, ResponseFunction>();
    for (const file of files) {  
        const statOfFile = await fs.stat(`${baseDir}/${file.name}`);
        if (statOfFile.isDirectory()) {
            const dir = file.name;
            // If the file is a directory, we want to load all the .js files in that directory, 1 level deep
            const files = (await fs.readdir(`${baseDir}/${file.name}`)).filter(f => f.endsWith('.js'));
            for (const file of files) {
                const response = await import(`file://${baseDir}/${dir}/${file}`); // We append file:// to the path so that Node's ESM loader can successfully load the file
                if (checkForResponseFunction(response.default)) {
                    responses.set(file.replace('.js', ''), response.default); // We store the object from each response file in the map as a typed string
                }
            }
        } else {
        const response = await import(`file://${baseDir}/${file.name}`); // We append file:// to the path so that Node's ESM loader can successfully load the file
            if (checkForResponseFunction(response.default)) {
                responses.set(file.name.replace('.js', ''), response.default); // We store the object from each response file in the map as a typed string
            }
        }
    }
    return responses;
}

function checkForResponseFunction(response: any): response is ResponseFunction {
    return typeof response === 'function';
}

/* Response functions */
type ResponseFunction = (value: string, id: number) => Promise<{
    type: string;
    value: any;
}>;