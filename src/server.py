import socket
import threading

def start_backend_server(port, response_message):
    def handle_client(client_socket):
        request = client_socket.recv(1024)
        print(f"Received request on backend {port}:\n{request.decode()}")
        http_response = f"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n{response_message}"
        client_socket.sendall(http_response.encode())
        client_socket.close()

    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(("localhost", port))
    server_socket.listen(5)
    print(f"Backend server started on port {port}")

    while True:
        client_socket, _ = server_socket.accept()
        threading.Thread(target=handle_client, args=(client_socket,)).start()

backend_threads = [
    threading.Thread(target=start_backend_server, args=(8080, "Response from backend 8080")),
    threading.Thread(target=start_backend_server, args=(8081, "Response from backend 8081")),
    threading.Thread(target=start_backend_server, args=(8082, "Response from backend 8082")),
]

for thread in backend_threads:
    thread.start()

