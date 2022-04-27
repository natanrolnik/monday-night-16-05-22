//
//  SocketWrapper.swift
//  NutemegStars
//
//  Created by Natan Rolnik on 27/04/2022.
//

import Foundation

class SocketWrapper<T: Decodable>: NSObject, URLSessionWebSocketDelegate {
    private let session: URLSession
    private var isOpen = false
    var webSocket: URLSessionWebSocketTask?
    var receivedMessage: ((T) -> Void)?

    init(session: URLSession, urlString: String, receivedMessage: @escaping ((T) -> Void)) {
        self.session = session
        self.receivedMessage = receivedMessage

        super.init()

        if let url = URL(string: urlString) {
            openSocket(url: url)
        }
    }

    private func openSocket(url: URL) {
        webSocket = session.webSocketTask(with: .init(url: url))
        webSocket?.delegate = self
        registerReceive()
        webSocket?.resume()
    }

    private func registerReceive() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self?.processReceivedData(data)
                case .string(let string):
                    if let asData = string.data(using: .utf8) {
                        self?.processReceivedData(asData)
                    }
                @unknown default:
                    print("Unknown data")
                }
            case .failure(let error):
                print(error)
            }
            self?.registerReceive()
        }
    }

    private func processReceivedData(_ data: Data) {
        guard let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return
        }

        receivedMessage?(decoded)
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Socket \(webSocketTask.currentRequest?.url?.path ?? "No url") opened")
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Socket \(webSocketTask.currentRequest?.url?.path ?? "No url") closed")
    }
}

