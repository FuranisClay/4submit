package cangjie_gateway

import std.collection.ArrayList
import std.socket.*
import std.time.*
import std.sync.*
import std.net.*

public class Add {
    public var ip: String = "0.0.0.0"
    public var port: UInt16 = 10000
    public Add(ip: String,port: UInt16) {
        this.ip = ip
        this.port = port
    }
}

let servers = ArrayList([Add("192.168.173.102", 8080),Add("192.168.173.103", 8080),Add("192.168.173.104", 8080)])
var currentIndex = 0

func choose(): Add {
    let backend = servers[currentIndex]
    currentIndex = (currentIndex + 1) % servers.size
    return backend
}

func redirect(requestContext: Array<Byte>,backadd:Add): Array<Byte> {
    let ret = Array<Byte>()
    try (back = TcpSocket(backadd.ip, backadd.port)) {
        back.connect()
        back.write(requestContext)
        let ret = Array<Byte>(256, item: 0)
        let res = back.read(ret)
        return ret
    }
    return ret
}

main() {
    try (server = TcpServerSocket(bindAt: 80)) {
        server.bind();
        while (true) {
            let client = server.accept();
                var backadd = choose()
                let ret = Array<Byte>(256, item: 0);
                let count = client.read(ret);
                let response = redirect(ret,backadd);
                client.write(response);
                client.close();
        }
    }
}
