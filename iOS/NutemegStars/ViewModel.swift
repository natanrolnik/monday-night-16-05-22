//
//  ViewModel.swift
//  NutemegStars
//
//  Created by Natan Rolnik on 27/04/2022.
//

import Shared
import SwiftUI

class ViewModel: ObservableObject {
    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
    private let serverHost = "localhost:8080"

    @Published var showingRaffle = false
    @Published private(set) var raffleStatus = RaffleStatus.idle
    @Published private(set) var ranking: [UserNutmegs]?
    @Published var liveCounter: Int = 0

    init() {
        openNutmegSocket()
        openRaffleSocket()
    }

    func startRaffle() {
        guard let url = URL(string: httpURL(for: "/raffle/start")) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = session.dataTask(with: request)
        task.resume()
    }

    func openNutmegSocket() {
        let urlString = websocketURL(for: "/nutmegs/live")
        _ = SocketWrapper<NutmegsSummary>(session: session, urlString: urlString) { summary in
            DispatchQueue.main.async {
                self.liveCounter = summary.today
            }
        }
    }

    func openRaffleSocket() {
        let urlString = websocketURL(for: "/raffle/live")
        _ = SocketWrapper<RaffleStatus>(session: session, urlString: urlString) { status in
            DispatchQueue.main.async {
                self.showingRaffle = !status.isIdle
                self.raffleStatus = status
            }
        }
    }

    func loadRanking() {
        guard let url = URL(string: httpURL(for: "/nutmegs/ranking")) else {
            return
        }

        session.dataTask(with: url) { data, meh, error in
            guard let data = data,
                  let ranking = try? JSONDecoder().decode(NutmegsRanking.self, from: data) else {
                return
            }

            DispatchQueue.main.async {
                self.ranking = ranking.ranking
            }
        }.resume()
    }

    private func websocketURL(for path: String) -> String {
        "ws://" + serverHost + path
    }

    private func httpURL(for path: String) -> String {
        "http://" + serverHost + path
    }
}
