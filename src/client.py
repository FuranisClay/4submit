import time
import socket
import threading

def simulate_client_request():
    while True:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
            client_socket.connect(("localhost", 80))
            request = "GET /api/test HTTP/1.1\r\nHost: localhost\r\n\r\n"
            client_socket.sendall(request.encode())

            response = client_socket.recv(4096)
            print(f"Client received response:\n{response.decode()}")
        
        time.sleep(2)

simulate_client_thread = threading.Thread(target=simulate_client_request)
simulate_client_thread.start()
