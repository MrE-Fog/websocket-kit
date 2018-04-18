extension WebSocket {
    /// Creates an `HTTPProtocolUpgrader` that will create instances of this class upon HTTP upgrade.
    ///
    /// Use this with `HTTPServer.start(...)`.
    public static func httpProtocolUpgrader(
        shouldUpgrade: @escaping (HTTPRequest) -> (HTTPHeaders?),
        onUpgrade: @escaping (WebSocket, HTTPRequest) -> ()
    ) -> HTTPProtocolUpgrader {
        return WebSocketUpgrader(shouldUpgrade: { head in
            let req = HTTPRequest(
                method: head.method,
                url: head.uri,
                version: head.version,
                headers: head.headers
            )
            return shouldUpgrade(req)
        }, upgradePipelineHandler: { channel, head in
            var req = HTTPRequest(
                method: head.method,
                url: head.uri,
                version: head.version,
                headers: head.headers
            )
            req.channel = channel
            let webSocket = WebSocket(channel: channel)
            return channel.pipeline.add(webSocket: webSocket).map {
                onUpgrade(webSocket, req)
            }
        })
    }
}
