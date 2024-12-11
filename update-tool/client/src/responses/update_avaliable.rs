
// This file is responsible for handling the response from the server when an update is available. (Pulling and then reporting status)
pub fn run(repo_path: &String, socket: &mut tungstenite::WebSocket<tungstenite::stream::MaybeTlsStream<std::net::TcpStream>>, parsed_msg: &json::JsonValue) {
    let pull_cmd = crate::utils::git::git_pull(&repo_path);
    if pull_cmd {
        crate::utils::nixos::rebuild_system(&repo_path);
        socket.write_message(tungstenite::Message::Text(json::stringify(json::object! {
            type: "updateSuccess",
            value: "",
            id: parsed_msg["id"].as_str()
        }))).expect("Failed to send message");
    } else {
        socket.write_message(tungstenite::Message::Text(json::stringify(json::object! {
            type: "updateError",
            value: "",
            id: parsed_msg["id"].as_str()
        }))).expect("Failed to send message");
    }
}