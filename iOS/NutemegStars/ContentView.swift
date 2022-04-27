//
//  ContentView.swift
//  NutemegStars
//
//  Created by Natan Rolnik on 27/04/2022.
//

import SwiftUI
import Shared
import ConfettiSwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack {
            VStack {
                Text("Nutmeg Stars ⚽️")
                    .font(.largeTitle)
                    .padding()

                HStack {
                    Button {
                        viewModel.loadRanking()
                    } label: {
                        Image(systemName: "arrow.clockwise.circle")
                            .imageScale(.large)
                    }

                    Spacer()
                        .frame(width: 80)

                    Button {
                        viewModel.startRaffle()
                    } label: {
                        Image(systemName: "ticket.fill")
                            .imageScale(.large)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.systemBackground))

            VStack {
                if let ranking = viewModel.ranking {
                    List {
                        Section(header: Text("Ranking")) {
                            ForEach(ranking) {
                                Text($0.user.name + ": \($0.count)")
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)

            Text("\(viewModel.liveCounter)")

            Image("NutmegNet")
                .resizable()
                .frame(width: 80, height: 80)
                .aspectRatio(contentMode: .fit)
                .confettiCannon(counter: $viewModel.liveCounter,
                                num: 1,
                                confettis: [.text("⚽️"), .text("🦵🏻"), .text("⚽️")],
                                confettiSize: 40,
//                                rainHeight: <#T##CGFloat#>,
                                fadesOut: true)
//                                repetitions: <#T##Int#>,
//                                repetitionInterval: <#T##Double#>)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            viewModel.loadRanking()
        }
        .sheet(isPresented: $viewModel.showingRaffle) {
            VStack {
                Text(viewModel.raffleStatus.title)
                    .font(Font.largeTitle)
                if let name = viewModel.raffleStatus.name {
                    Spacer()
                        .frame(height: 40)
                    Text(name)
                        .font(Font.title)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(viewModel.raffleStatus.backgroundColor))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
                .previewDevice("iPad mini (6th generation)")
        }
    }
}

extension UserNutmegs: Identifiable {
    public var id: UUID {
        user.id
    }
}

extension RaffleStatus {
    var title: String {
        switch self {
        case .idle:
            return "Waiting..."
        case .started:
            return "Raffle is on!"
        case .running:
            return "Who will win?"
        case .finished:
            return "Winner:"
        }
    }
    var name: String? {
        switch self {
        case .idle, .started: return nil
        case .running(let name): return name
        case .finished(let user): return user.name
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .idle, .started:
            return .systemBackground
        case .running:
            return UIColor.palette.randomElement()!
        case .finished:
            return .rgb(26, 188, 156)
        }
    }
}

extension UIColor {
    static let palette: [UIColor] = [
        .rgb(52, 152, 219),
        .rgb(142, 68, 173),
        .rgb(189, 195, 199),
        .rgb(241, 196, 15),
        .rgb(253, 121, 168),
        .rgb(255, 177, 66),
        .rgb(255, 82, 82)
    ]

    static func rgb(_ r: Int, _ g: Int, _ b: Int, _ alpha: CGFloat = 1) -> UIColor {
        UIColor(
            red: CGFloat(r)/CGFloat(255),
            green: CGFloat(g)/CGFloat(255),
            blue: CGFloat(b)/CGFloat(255),
            alpha: alpha
        )
    }
}
