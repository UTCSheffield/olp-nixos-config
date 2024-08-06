pub mod install;

use json::object;
use tungstenite::Message;
use crate::utils;

// This function runs when no subcommand is provided -> this is the default behavior
pub fn run(wss_path: &String, repo_path: &String) {
    println!("Starting WS connection");
    let mut socket = utils::websocket::ws_connect(&wss_path);
    loop {
        // Grab the response from the ws connection
        let msg = socket.read().expect("Failed to read message");
        // We want to ignore ping messages
        if msg.is_text() {
            println!("Received: {}", msg);
            let parsed_msg = json::parse(msg.to_text().unwrap()).expect("Failed to parse JSON");
            // Rust equivalent of a switch statement
            match parsed_msg["type"].as_str().unwrap() {
                "configVersion" => {
                    // Send a json string of the current git hash
                    let current_version = utils::git::git_get_latest_hash(repo_path.as_str());
                    socket.send(Message::Text(object!{
                        "type": "currentVersion",
                        value: current_version,
                        id: parsed_msg["id"].as_str(),
                        }.to_string())).expect("Failed to send message");
                    },
                "updateAvaliable" => {
                    // Pull the latest changes from the git repo
                    println!("{}", utils::git::git_pull(repo_path.as_str()));
                }
                _ => todo!(),
            };
        }
    }
}