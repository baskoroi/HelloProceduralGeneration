//
//  GameScene+GameStateExtension.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/13/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

extension GameScene: GameStateDelegate {
    
    func setupGameState() {
        guard let energySprite = energyBarHandler.sprite else { return }
        
        let timerLabel = SKLabelNode()
        timerLabel.text = "00:00"
        timerLabel.zPosition = 5
        timerLabel.fontSize = 12
        timerLabel.fontName = "HelveticaNeue-Medium"
        timerLabel.position = CGPoint(x: -36, y: 10)
        gameStateHandler.timerLabel = timerLabel
        energySprite.addChild(timerLabel)
        
        let countTimeAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.run { [weak self] in
                self?.gameStateHandler.secondsElapsed += 1
            }
        ]))
        run(countTimeAction)
    }
    
    func lose() {
        gameStateHandler.isWon = false
    }
    
    func win() {
        gameStateHandler.isWon = true
    }
    
    func updateTimerDisplay() {
        guard let timerLabel = gameStateHandler.timerLabel else { return }
        let timeString = gameStateHandler.secondsElapsed.asTimeString(style: .positional)
        timerLabel.text = timeString
    }
}

// credits & reference:
// https://stackoverflow.com/questions/26794703/swift-integer-conversion-to-hours-minutes-seconds
extension Double {
    func asTimeString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second, .nanosecond]
        formatter.unitsStyle = style
        formatter.zeroFormattingBehavior = .pad
        guard let formattedString = formatter.string(from: self) else { return "" }
        return formattedString
    }
}
