use tungstenite::{connect, stream::MaybeTlsStream, WebSocket};
pub fn ws_connect(location: &String) -> WebSocket<MaybeTlsStream<std::net::TcpStream>> {
    let (socket, _response) = connect(location).expect("Failed to connect");
    println!("Connected to the server");
    return socket;
}