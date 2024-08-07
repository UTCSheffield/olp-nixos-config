use json::object;
use tungstenite::Message;

// Sends the current git hash to the update server
pub fn run(repo_path: &String, socket: &mut tungstenite::WebSocket<tungstenite::stream::MaybeTlsStream<std::net::TcpStream>>, parsed_msg: &json::JsonValue) {
    let current_version = crate::utils::git::git_get_latest_hash(repo_path.as_str());
    socket.send(Message::Text(object!{
        "type": "currentVersion",
        value: current_version,
        id: parsed_msg["id"].as_str(),
    }.to_string())).expect("Failed to send message");
}