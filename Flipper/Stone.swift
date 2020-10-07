//
//  Stone.swift
//  Flipper
//
//  Created by Stanly Shiyanovskiy on 07.10.2020.
//

import SpriteKit
import UIKit

public final class Stone: SKSpriteNode {
    private static let thinkingTexture = SKTexture(imageNamed: "thinking")
    private static let whiteTexture = SKTexture(imageNamed: "white")
    private static let blackTexture = SKTexture(imageNamed: "black")

    public func setPlayer(_ player: StoneColor) {
        if player == .white {
            texture = Stone.whiteTexture
        } else if player == .black {
            texture = Stone.blackTexture
        } else if player == .choice {
            texture = Stone.thinkingTexture
        }
    }

    public var row = 0
    public var col = 0
}
