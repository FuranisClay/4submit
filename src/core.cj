package cangjieGateway

// import std.socket.*
// import std.time.*
// import std.sync.*
// import std.collection.ArrayList
// import std.net.*

// public class TcpServerAddress {
//     TcpServerAddress(
//         public let host: String,
//         public let port: UInt16
//     ){}
// }


// public class TcpProxyServer {
//     public TcpProxyServer(
//         private let port: UInt16,
//         private let backends: ArrayList<TcpServerAddress>,
//         private let loadBalancer!: LoadBalancer = RoundRobinLoadBalancer(backends) // 默认轮询
//     ){}

//     public func start() {
//         try (serverSocket = TcpServerSocket(bindAt: this.port)) {
//             serverSocket.bind();
//             println("Proxy server started on port ${this.port}")

//             while (true) {
//                 let client = serverSocket.accept();
//                 spawn {
//                     TcpConnection(client, loadBalancer.selectBackend()).handle()
//                 }
//             }
//         }
//     }
// }

// public class TcpConnection {
//     public TcpConnection(
//         private let client: TcpSocket,
//         private let backend: TcpServerAddress
//     ){}

//     public func handle() {
//         // 从客户端读取请求数据
//         let buf = Array<Byte>(1024, item: 0);
//         let count = client.read(buf);
        
//         // 转发请求到后端服务器
//         let response = forwardToBackend(buf.slice(0, count));

//         // 将响应发送回客户端
//         client.write(response);
//         client.close();
//     }

//     private func forwardToBackend(request: Array<Byte>): Array<Byte> {
//         try (backendSocket = TcpSocket(backend.host, backend.port)) {
//             backendSocket.connect()
//             backendSocket.write(request)
            
//             // 接收后端服务器响应
//             let response = Array<Byte>(1024, item: 0)
//             let responseSize = backendSocket.read(response)
//             return response.slice(0, responseSize)
//         }

//         return Array<Byte>()
//     }
// }

// public interface LoadBalancer {
//     func selectBackend(): TcpServerAddress
// }

// public class RoundRobinLoadBalancer <: LoadBalancer {
//     private var currentIndex = 0
    
//     public RoundRobinLoadBalancer(
//         private let backends: ArrayList<TcpServerAddress>
//     ){}

//     public func selectBackend(): TcpServerAddress {
//         let backend = backends[currentIndex]
//         currentIndex = (currentIndex + 1) % backends.size
//         return backend
//     }
// }