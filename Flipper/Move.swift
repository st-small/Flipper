//
//  Move.swift
//  Flipper
//
//  Created by Stanly Shiyanovskiy on 07.10.2020.
//

import GameplayKit
import UIKit

public final class Move: NSObject, GKGameModelUpdate {

    public var value = 0

    public var row: Int
    public var col: Int

    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
}
