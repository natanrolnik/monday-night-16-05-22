import Foundation

public enum RaffleStatus: Codable {
    case idle
    case started
    case running(candidate: String, color: Color)
    case finished(winner: User, color: Color)
}

extension RaffleStatus {
    public var isIdle: Bool {
        switch self {
        case .idle: return true
        default: return false
        }
    }
}

public struct RaffleStatusPayload: Codable {
    public let status: RaffleStatus

    public init(status: RaffleStatus) {
        self.status = status
    }
}
