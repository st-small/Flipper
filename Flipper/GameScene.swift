//
//  GameScene.swift
//  Flipper
//
//  Created by Stanly Shiyanovskiy on 07.10.2020.
//

import SpriteKit
import GameplayKit

public final class GameScene: SKScene {
    
    private var board: Board!
    private var rows = [[Stone]]()
    
    private var strategist: GKMonteCarloStrategist!
    
    public override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.blendMode = .replace
        background.zPosition = 1
        addChild(background)

        let gameBoard = SKSpriteNode(imageNamed: "board")
        gameBoard.name = "board"
        gameBoard.zPosition = 2
        addChild(gameBoard)
        
        board = Board()

        let offsetX = -280
        let offsetY = -281
        let stoneSize = 80

        for row in 0 ..< Board.size {
            var colArray = [Stone]()

            for col in 0 ..< Board.size {
                let stone = Stone(color: UIColor.clear, size: CGSize(width: stoneSize, height: stoneSize))
                stone.position = CGPoint(x: offsetX + (col * stoneSize), y: offsetY + (row * stoneSize))

                stone.row = row
                stone.col = col

                gameBoard.addChild(stone)
                colArray.append(stone)
            }

            board.rows.append([StoneColor](repeating: .empty, count: Board.size))
            rows.append(colArray)
        }

        rows[4][3].setPlayer(.white)
        rows[4][4].setPlayer(.black)
        rows[3][4].setPlayer(.white)
        rows[3][3].setPlayer(.black)

        board.rows[4][3] = .white
        board.rows[4][4] = .black
        board.rows[3][4] = .white
        board.rows[3][3] = .black

        strategist = GKMonteCarloStrategist()
        strategist.budget = 100
        strategist.explorationParameter = 1
        strategist.randomSource = GKRandomSource.sharedRandom()
        strategist.gameModel = board
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let gameBoard = childNode(withName: "board") else { return }

        let location = touch.location(in: gameBoard)

        // find the stone that was tapped
        let nodesAtPoint = nodes(at: location)
        let tappedStones = nodesAtPoint.filter { $0 is Stone }
        guard tappedStones.count > 0 else { return }

        let tappedStone = tappedStones[0] as! Stone

        if board.canMoveIn(row: tappedStone.row, col: tappedStone.col) {
            makeMove(row: tappedStone.row, col: tappedStone.col)

            if board.currentPlayer.stoneColor == .white {
                makeAIMove()
            }
        } else {
            print("Move is illegal")
        }
    }
    
    private func makeMove(row: Int, col: Int) {
        // find the list of captured stones
        let captured = board.makeMove(player: board.currentPlayer, row: row, col: col)

        for move in captured {
            // pull out the sprite for each captured stone
            let stone = rows[move.row][move.col]

            // update who owns it
            stone.setPlayer(board.currentPlayer.stoneColor)

            // make it 120% of its normal size
            stone.xScale = 1.2
            stone.yScale = 1.2

            // animate it down to 100%
            stone.run(SKAction.scale(to: 1, duration: 0.5))
        }

        // change players
        board.currentPlayer = board.currentPlayer.opponent
    }
    
    private func makeAIMove() {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let strategistTime = CFAbsoluteTimeGetCurrent()
            guard let move = self.strategist.bestMoveForActivePlayer() as? Move else { return }
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime

            DispatchQueue.main.async { [unowned self] in
                self.rows[move.row][move.col].setPlayer(.choice)
            }

            let aiTimeCeiling = 3.0
            let delay = min(aiTimeCeiling - delta, aiTimeCeiling)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [unowned self] in
                self.makeMove(row: move.row, col: move.col)
            }
        }
    }
}
