import Foundation
import Vapor

class WebSocketsWrapper {
    private var webSockets = [WebSocket]()

    func register(_ ws: WebSocket) {
        webSockets.append(ws)

        ws.onClose.whenComplete { [weak self] _ in
            if let index = self?.webSockets.firstIndex(where: { $0 === ws }) {
                self?.webSockets.remove(at: index)
            }
        }
    }

    func send(_ text: String) {
        webSockets.forEach { $0.send(text) }
    }
}
