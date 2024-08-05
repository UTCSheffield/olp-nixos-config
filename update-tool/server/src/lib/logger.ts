import { green, red, yellow } from "colorette";

class Logger {
    private loglevel: string = process.env.LOG_LEVEL || "INFO";
    constructor() {
    }
    public info(message: string) {
        // We always log INFO messages
        this.log(`${green(message)}`, "INFO");
    }
    public debug(message: string) {
        // We only want to log DEBUG messages if the loglevel is set to DEBUG
        if (this.loglevel !== "DEBUG") return;
        this.log(`${yellow(message)}`, "DEBUG");
    }
    public error(message: string) {
        // We always log ERROR messages
        this.log(`${red(message)}`, "ERROR");
    }
    private log(message: string, level: string) {
        console.log(`${level}: ${message}`);
    }
}

export const logger = new Logger();