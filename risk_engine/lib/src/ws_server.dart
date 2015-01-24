part of risk_engine.server;


abstract class AbstractRiskWsServer {
  final Map<int, WebSocket> _clients = {};

  RiskGameEngine get engine;

  Codec<Object, Map> get engineEventCodec;

  int currentPlayerId = 1;

  void handleWebSocket(WebSocket ws) {
    final playerId = connectPlayer(ws);
    listen(ws, playerId);
  }

  void listen(Stream ws, int playerId);

  int connectPlayer(WebSocket ws) {
    int playerId = currentPlayerId++;

    _clients[playerId] = ws;

    // Concate streams: Welcome event, history events, incoming events
    var stream = new StreamController();
    stream.add(new Welcome()..playerId = playerId);
    engine.history.forEach(stream.add);
    stream.addStream(engine.outputStream.stream);

    ws.addStream(stream.stream.map(engineEventCodec.encode).map(logEvent("OUT", playerId)).map(JSON.encode));

    print("Player $playerId connected");
    return playerId;
  }

  logEvent(String direction, int playerId) => (event) {
    print("$direction[$playerId] - $event");
    return event;
  };
}


Future<HttpServer> startServer(int port, String path) {
  VirtualDirectory vDir;

  void directoryHandler(dir, request) {
    final indexUri = new Uri.file(dir.path).resolve('index.html');
    vDir.serveFile(new File(indexUri.toFilePath()), request);
  }

  path = Platform.script.resolve(path).toFilePath();
  return runZoned(() {
    return HttpServer.bind(InternetAddress.ANY_IP_V4, port).then((server) {
      print("Risk is running on http://localhost:$port\nBase path: $path");
      vDir = new VirtualDirectory(path)
          ..jailRoot = false
          ..allowDirectoryListing = true
          ..directoryHandler = directoryHandler;
      var riskServer = new RiskWsServer();
      server.listen((HttpRequest req) {
        if (req.uri.path == '/ws') {
          WebSocketTransformer.upgrade(req).then(riskServer.handleWebSocket);
        } else if (req.uri.path == '/new') {
          riskServer = new RiskWsServer();
          req.response.redirect(req.uri.resolve('/'));
        } else {
          vDir.serveRequest(req);
        }
      });

      return server;
    });
  }, onError: (e) => print("An error occurred $e"));
}

class RiskWsServer extends AbstractRiskWsServer {
  final RiskGameEngine engine;

  Codec<Object, Map> get engineEventCodec => EVENT;

  RiskWsServer() : this.fromEngine(new RiskGameEngine(new StreamController.broadcast(), new RiskGameStateImpl()));
  RiskWsServer.fromEngine(this.engine);

  void listen(Stream ws, int playerId) {
    // Decode JSON
    ws.map(JSON.decode)// Log incoming events
    .map(logEvent("IN", playerId))// Decode events
    .map(EVENT.decode)// Avoid unknown events and cheaters
    .where((event) => event is PlayerEvent && event.playerId == playerId)// Handle events in game engine
    .listen(engine.handle)// Connection closed
    .onDone(() => print("Player $playerId left"));
  }
}
