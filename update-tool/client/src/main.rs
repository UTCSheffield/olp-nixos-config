mod cli_commands;
pub mod utils;
pub mod responses;

use clap::{Parser, Subcommand, command};

#[derive(Parser)]
#[command(version, about, long_about = None, arg_required_else_help = false)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,

    // Our global arguments
    #[arg(short, long, default_value_t = String::from("ws://localhost:8080"))]
    wss_path: String,

    #[arg(short, long, default_value_t = String::from("/etc/nixos"))]
    repo_path: String
}

// Add subcommands here
#[derive(Subcommand)]
enum Commands {
    Install {
        package: Option<String>
    },
    Upgrade {}
}

fn main() {
    let cli = Cli::parse();
    // Rust version of a switch statement
    match &cli.command {
        Some(Commands::Install { package }) => cli_commands::install::run(package.as_ref().unwrap()),
        Some(Commands::Upgrade {}) => cli_commands::upgrade::run(),
        None => cli_commands::run(&cli.wss_path, &cli.repo_path),
    };
}