//
//  Player.swift
//  Flipper
//
//  Created by Stanly Shiyanovskiy on 07.10.2020.
//

import GameplayKit
import UIKit

public final class Player: NSObject, GKGameModelPlayer {

    public static let allPlayers = [Player(stone: .black), Player(stone: .white)]
    public var stoneColor: StoneColor
    public var playerId: Int

    public init(stone: StoneColor) {
        stoneColor = stone
        playerId = stone.rawValue
    }

    public var opponent: Player {
        if stoneColor == .black {
            return Player.allPlayers[1]
        } else {
            return Player.allPlayers[0]
        }
    }
}
