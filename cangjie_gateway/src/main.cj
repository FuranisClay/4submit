package cangjie_gateway

import std.collection.ArrayList
import std.socket.*
import std.time.*
import std.sync.*
import std.net.*

public class Add {
    Add(
        public let host: String,
        public let port: UInt16
    ){}
}

let servers = ArrayList(
    [
        Add("192.168.173.102", 8080),
        Add("192.168.173.103", 8080),
        Add("192.168.173.104", 8080)
    ]
)
var currentIndex = 0

func selectBackend(): Add {
    let backend = servers[currentIndex]
    currentIndex = (currentIndex + 1) % servers.size
    return backend
}

func forwardToBackend(request: Array<Byte>,backend:Add): Array<Byte> {
    try (backendSocket = TcpSocket(backend.host, backend.port)) {
        backendSocket.connect()
        backendSocket.write(request)

        // 接收后端服务器响应
        let response = Array<Byte>(1024, item: 0)
        let responseSize = backendSocket.read(response)
        return response.slice(0, responseSize)
    }

    return Array<Byte>()
}

main() {
    try (serverSocket = TcpServerSocket(bindAt: 80)) {
        serverSocket.bind();
        while (true) {
            let client = serverSocket.accept();
            spawn {
                var backend = selectBackend()
                let buf = Array<Byte>(1024, item: 0);
                let count = client.read(buf);
                let response = forwardToBackend(buf.slice(0, count),backend);
                client.write(response);
                client.close();
            }
        }
    }
}
