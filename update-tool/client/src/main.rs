mod utils;
use json::object;
use tungstenite::Message;

fn main() {
    let cmd = clap::Command::new("sys")
        .bin_name("sys")
        .arg(
            clap::arg!(--"repo-path" <PATH>)
                .default_value("/etc/nixos"),
        )
        .arg(
            clap::arg!(--"wss-path" <PATH>)
                .default_value("ws://localhost:8080"),
        );
    let matches = cmd.get_matches();
    match matches.subcommand() {
        _ => {
            println!("Starting WS connection");
            let mut socket = utils::websocket::ws_connect(matches.get_one::<String>("wss-path").unwrap());
            loop {
                // Grab the response from the ws connection
                let msg = socket.read_message().expect("Failed to read message");
                // We want to ignore ping messages
                if msg.is_text() {
                    println!("Received: {}", msg);
                    let parsed_msg = json::parse(msg.to_text().unwrap()).expect("Failed to parse JSON");
                    // Rust equivalent of a switch statement
                    match parsed_msg["type"].as_str().unwrap() {
                        "configVersion" => {
                            // Send a json string of the current git hash
                            let current_version = utils::git::git_get_latest_hash(matches.get_one::<String>("repo-path").unwrap());
                           socket.send(Message::Text(object!{
                                "type": "currentVersion",
                                value: current_version,
                                id: parsed_msg["id"].as_str(),
                           }.to_string())).expect("Failed to send message");
                        },
                        "updateAvaliable" => {
                            // Pull the latest changes from the git repo
                            println!("{}", utils::git::git_pull(matches.get_one::<String>("repo-path").unwrap()));
                        }
                        _ => todo!(),
                    };
                }
            }
        }
    }
}