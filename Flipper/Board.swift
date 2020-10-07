//
//  Board.swift
//  Flipper
//
//  Created by Stanly Shiyanovskiy on 07.10.2020.
//

import GameplayKit
import UIKit

public final class Board: NSObject, GKGameModel {

    public static let size = 8

    public var rows = [[StoneColor]]()
    public var currentPlayer = Player.allPlayers[0]
    
    public var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }

    public var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    private static let moves = [
        Move(row: -1, col: -1), Move(row: 0, col: -1), Move(row: 1, col: -1),
        Move(row: -1, col: 0), Move(row: 1, col: 0),
        Move(row: -1, col: 1), Move(row: 0, col: 1), Move(row: 1, col: 1)
    ]
    
    private func isInBounds(row: Int, col: Int) -> Bool {
        if row < 0 { return false }
        if col < 0 { return false }
        if row >= Board.size { return false }
        if col >= Board.size { return false }
        return true
    }
    
    public func canMoveIn(row: Int, col: Int) -> Bool {
        // check move is sensible
        if !isInBounds(row: row, col: col) { return false }

        // check move hasn't been made already
        let stone = rows[row][col]
        if stone != .empty { return false }

        // check the move is legal
        for move in Board.moves {
            var passedOpponent = false

            var currentRow = row
            var currentCol = col

            // count from here up to the edge of the board, applying our move each time
            for _ in 0 ..< Board.size {
                currentRow += move.row
                currentCol += move.col

                guard isInBounds(row: currentRow, col: currentCol) else { break }
                let stone = rows[currentRow][currentCol]

                if (stone == currentPlayer.opponent.stoneColor) {
                    // we found an enemy stone
                    passedOpponent = true
                } else if stone == currentPlayer.stoneColor && passedOpponent {
                    // we found one of our stones after finding an enemy stone
                    return true
                } else {
                    // we found something else; bail out
                    break
                }
            }
        }

        // if we're still here it means we failed
        return false
    }
    
    public func makeMove(player: Player, row: Int, col: Int) -> [Move] {
        // 1: create an array to hold all captured stones
        var didCapture = [Move]()

        // 2: place a stone in the requested position
        rows[row][col] = player.stoneColor
        didCapture.append(Move(row: row, col: col))

        for move in Board.moves {
            // 3: look in this direction for captured stones
            var mightCapture = [Move]()
            var currentRow = row
            var currentCol = col

            // 4: count from here up to the edge of the board, applying our move each time
            for _ in 0 ..< Board.size {
                currentRow += move.row
                currentCol += move.col

                // 5: make sure this is a sensible position to move to
                guard isInBounds(row: currentRow, col: currentCol) else { break }
                let stone = rows[currentRow][currentCol]

                if stone == player.opponent.stoneColor {
                    // 6: we found an enemy stone – add it to the list of possible captures
                    mightCapture.append(Move(row: currentRow, col: currentCol))
                } else if stone == player.stoneColor {
                    // 7: we found one of our stones - add the mightCapture array to didCapture
                    didCapture.append(contentsOf: mightCapture)

                    // 8: change all stones to the player's color, then exit the loop because we're finished in this direction
                    mightCapture.forEach {
                        rows[$0.row][$0.col] = player.stoneColor
                    }

                    break
                } else {
                    // 9: we found something else; bail out
                    break
                }
            }
        }

        // 10: send back the list of captured stones
        return didCapture
    }
    
    private func getScores() -> (black: Int, white: Int) {
        var black = 0
        var white = 0

        rows.forEach {
            $0.forEach {
                if $0 == .black {
                    black += 1
                } else if $0 == .white {
                    white += 1
                }
            }
        }

        return (black, white)
    }

    public func isWin(for player: GKGameModelPlayer) -> Bool {
        guard let playerObject = player as? Player else { return false }
        let scores = getScores()

        if playerObject.stoneColor == .black {
            return scores.black > scores.white + 10
        } else {
            return scores.white > scores.black + 10
        }
    }
    
    public func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        // safely unwrap the player object
        guard let playerObject = player as? Player else { return nil }

        // if the game is over exit now
        if isWin(for: playerObject) || isWin(for: playerObject.opponent) {
            return nil
        }

        // if we're still here prepare to send back a list of moves
        var moves = [Move]()

        // try every column in every row
        for row in 0 ..< Board.size {
            for col in 0 ..< Board.size {
                if canMoveIn(row: row, col: col) {
                    // this move is possible; add it to the list
                    moves.append(Move(row: row, col: col))
                }
            }
        }

        return moves
    }
    
    public func apply(_ gameModelUpdate: GKGameModelUpdate) {
        guard let move = gameModelUpdate as? Move else { return }
        _ = makeMove(player: currentPlayer, row: move.row, col: move.col)
        currentPlayer = currentPlayer.opponent
    }

    public func setGameModel(_ gameModel: GKGameModel) {
        guard let board = gameModel as? Board else { return }
        currentPlayer = board.currentPlayer
        rows = board.rows
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = Board()
        copy.setGameModel(self)
        return copy
    }
}
