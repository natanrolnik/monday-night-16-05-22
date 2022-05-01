import Foundation

public struct Color: Codable {
    public let r: Int
    public let g: Int
    public let b: Int
    public let a: Float

    public init(red: Int, green: Int, blue: Int, alpha: Float = 1) {
        self.r = red
        self.g = green
        self.b = blue
        self.a = alpha
    }

    public init(_ r: Int, _ g: Int, _ b: Int, _ a: Float = 1) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}

#if canImport(UIKit)

import UIKit

private let divisor = CGFloat(255)

extension Shared.Color {
    public var asUIColor: UIColor {
        .init(red: CGFloat(r) / divisor,
              green: CGFloat(g) / divisor,
              blue: CGFloat(b) / divisor,
              alpha: CGFloat(a))
    }
}

#endif
