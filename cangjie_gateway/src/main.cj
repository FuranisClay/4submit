package cangjie_gateway

import net.http.*
import std.socket.*
import std.sync.*
import std.collection.HashMap



var currentIndex = 0
// 后端服务器列表
var backendServers = [
    "http://192.168.173.102:8080",
    "http://192.168.173.103:8080",
    "http://192.168.173.104:8080"
]

// 基本连接功能，转发请求到指定后端
func proxyRequest(httpContext: HttpContext) {
    let path = httpContext.request.url.toString()
    println(path)
    if (path == "/api/default") {
        let backendServer = backendServers[0]  // 在示例中，默认转发到第一个后端服务器
        let client = ClientBuilder().build()
        let backendResponse = client.send(HttpRequestBuilder().url(backendServer + path).build())
        httpContext.responseBuilder.body(backendResponse.body)
        client.close()
    }
}

// 负载均衡转发
func loadBalanceProxyRequest(httpContext: HttpContext) {

    let path = httpContext.request.url.toString()
     println(path)
    if (path == "/api/loadbalance") {
        let backendServer = backendServers[currentIndex]
        currentIndex = (currentIndex + 1) % backendServers.size  // ROUND_ROBIN 负载均衡
        let client = ClientBuilder().build()
        let backendResponse = client.send(HttpRequestBuilder().url(backendServer + path).build())
        httpContext.responseBuilder.body(backendResponse.body)
    }
}


func rewritePathProxyRequest(httpContext: HttpContext) {
    let path = httpContext.request.url.toString()
     println(path)
    if (path == "/api/rewrite") {
        let newPath = "/api/default"  // 重写路径
        let backendServer = backendServers[currentIndex]
        currentIndex = (currentIndex + 1) % backendServers.size  // ROUND_ROBIN
        let client = ClientBuilder().build()
        let backendResponse = client.send(HttpRequestBuilder().url(backendServer + newPath).build())
        httpContext.responseBuilder.body(backendResponse.body)
    }
}


func uaRewriteProxyRequest(httpContext: HttpContext) {
    let path = httpContext.request.url.toString()
     println(path)
    if (path == "/api/uarewrite") {
        let newUserAgent = "NEU-Cangjie"  // 重写User-Agent
        httpContext.request.headers.set("User-Agent", newUserAgent)
        // httpContext.request.headers["User-Agent"] = newUserAgent
        let backendServer = backendServers[currentIndex]
        currentIndex = (currentIndex + 1) % backendServers.size // ROUND_ROBIN
        let client = ClientBuilder().build()
        let backendResponse = client.send(HttpRequestBuilder().url(backendServer + path).build())
        httpContext.responseBuilder.body(backendResponse.body)
    }
}

main () {
    // 1. 构建 Server 实例
    let server = ServerBuilder()
                        .addr("192.168.173.101")
                        .port(80)  
                        .build()
    
    // 2. 注册 HttpRequestHandler
    server.distributor.register("/api/default", proxyRequest)
    server.distributor.register("/api/loadbalance", loadBalanceProxyRequest)
    server.distributor.register("/api/rewrite", rewritePathProxyRequest)
    server.distributor.register("/api/uarewrite", uaRewriteProxyRequest)

    // 3. 启动服务
    server.serve()
}
