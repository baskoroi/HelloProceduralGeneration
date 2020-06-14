//
//  GameScene+GameStateExtension.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/13/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

extension GameScene: GameStateDelegate, ButtonDelegate {
    
    func setupGameState() {
        guard let energySprite = energyBarHandler.sprite else { return }
        
        let timerLabel = SKLabelNode()
        timerLabel.text = "00:00"
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
        gameStateHandler.currentState = .lost
        
        showGameOver()
    }
    
    private func showGameOver() {
        
        guard let camera = cameraHandler.node else { return }
        
        let (screenWidth, screenHeight, screenScale) =
            (UIScreen.main.nativeBounds.width,
             UIScreen.main.nativeBounds.height,
             UIScreen.main.nativeScale)
        
        let gameOverScreen = SKSpriteNode(
            color: UIColor(white: 0, alpha: 0.4),
            size: CGSize(width: screenWidth, height: screenHeight))
        gameOverScreen.zPosition = 10
        camera.addChild(gameOverScreen)
        
        let title = SKLabelNode()
        title.text = "GAME OVER"
        title.fontSize = 48
        title.fontName = "PoiretOne-Regular"
        title.position = CGPoint(x: 0, y: 400)
        gameOverScreen.addChild(title)
        
        let outOfBatteryLogo = SKSpriteNode(imageNamed: "gameovericon")
        outOfBatteryLogo.position = CGPoint(x: 0, y: 120)
        outOfBatteryLogo.setScale(screenScale)
        gameOverScreen.addChild(outOfBatteryLogo)
        
        let sentence = SKLabelNode()
        sentence.text = "Your battery has died!"
        sentence.fontSize = 36
        sentence.fontName = "PoiretOne-Regular"
        sentence.position = CGPoint(x: 0, y: -120)
        gameOverScreen.addChild(sentence)
        
        let exitButton = Button(name: "exit")
        exitButton.delegate = self
        exitButton.position = CGPoint(x: -112, y: -440)
        exitButton.setScale(1.75)
        gameOverScreen.addChild(exitButton)
        
        let restartButton = Button(name: "restart")
        restartButton.delegate = self
        restartButton.position = CGPoint(x: 112, y: -440)
        restartButton.setScale(1.75)
        gameOverScreen.addChild(restartButton)
    }
    
    func win() {
        gameStateHandler.currentState = .won
    }
    
    func pause() {
        
    }
    
    func resume() {
        
    }
    
    func restart() {
        guard let view = self.view else { return }
        
        self.removeAllChildren()
        self.removeAllActions()
        
        let newGame = GameScene(size: self.size)
        let transition = SKTransition.fade(withDuration: 1.0)
        newGame.scaleMode = .aspectFill
        view.presentScene(newGame)
    }
    
    func updateTimerDisplay() {
        guard !energyBarHandler.isDead else { return }
        guard let timerLabel = gameStateHandler.timerLabel else { return }
        let timeString = gameStateHandler.secondsElapsed.asTimeString(style: .positional)
        timerLabel.text = timeString
    }
    
    func onButtonTap(name buttonName: String) {
        switch buttonName {
        case "exit":
            print("Exiting the game...")
        case "restart":
            print("Restarting the game...")
            restart()
        default:
            break
        }
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
