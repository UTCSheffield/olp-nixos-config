pub mod install;
pub mod upgrade;

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
                "configVersion" => crate::responses::config_version::run(repo_path, &mut socket, &parsed_msg),
                "updateAvaliable" => crate::responses::update_avaliable::run(repo_path, &mut socket, &parsed_msg),
                _ => todo!(),
            };
        }
    }
}