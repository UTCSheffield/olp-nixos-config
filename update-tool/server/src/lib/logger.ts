import { blue, red } from "colorette";

class Logger {
    constructor() {
    }
    public info(message: string) {
        this.log(`${blue(message)}`, "INFO");
    }
    public error(message: string) {
        this.log(`${red(message)}`, "ERROR");
    }
    private log(message: string, level: string) {
        console.log(`${level}: ${message}`);
    }
}

export const logger = new Logger();