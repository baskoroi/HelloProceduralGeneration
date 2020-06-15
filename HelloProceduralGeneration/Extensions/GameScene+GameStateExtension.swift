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
        // game state is already reset to playing, as per
        // GameStateHandler() init
        
        setupGameTimerDisplay()
        setupPauseButton()
        
        startTimer()
    }
    
    func startTimer() {
        let countTimeAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.run { [weak self] in
                self?.gameStateHandler.secondsElapsed += 1
            }
        ]))
        run(countTimeAction, withKey: "countTimer")
    }
    
    func pauseTimer() {
        removeAction(forKey: "countTimer")
    }
    
    func setupGameTimerDisplay() {
        guard let energySprite = energyBarHandler.sprite else { return }
        let timerLabel = SKLabelNode()
        timerLabel.text = "00:00"
        timerLabel.fontSize = 12
        timerLabel.fontName = "HelveticaNeue-Medium"
        timerLabel.position = CGPoint(x: -36, y: 10)
        gameStateHandler.timerLabel = timerLabel
        energySprite.addChild(timerLabel)
    }
    
    func setupPauseButton() {
        guard let camera = cameraHandler.node else { return }
        
        let (width, height) = (ScreenHelper.width, ScreenHelper.height)
        let pauseButton = SpriteButton(imageName: "pause", buttonName: "pause")
        pauseButton.delegate = self
        pauseButton.position = CGPoint(x: width / 2 + 100, y: height / 2 + 240)
        pauseButton.zPosition = 5
        pauseButton.setScale(2.5)
        camera.addChild(pauseButton)
    }
    
    func lose() {
        gameStateHandler.currentState = .lost
        
        showGameOver()
    }
    
    // black by default (whiteLevel = 0)
    // you can make white overlay with whiteLevel = 1
    private func showOverlay(on camera: SKCameraNode,
                             width: CGFloat,
                             height: CGFloat,
                             isWhite: Bool = false,
                             alpha: CGFloat = 0.4,
                             overlayNodeName: String = "") -> SKSpriteNode {
        
        let overlay = SKSpriteNode(
            color: UIColor(white: isWhite ? 1 : 0, alpha: alpha),
            size: CGSize(width: width, height: height))
        overlay.zPosition = 10
        
        if overlayNodeName != "" {
            overlay.name = overlayNodeName
        }
            
        camera.addChild(overlay)
        
        return overlay
    }
    
    private func addLabelOn(overlay: SKSpriteNode,
                            text: String,
                            fontSize: CGFloat,
                            position: CGPoint,
                            fontName: String = "PoiretOne-Regular") {
        
        let label = SKLabelNode()
        label.text = text
        label.fontSize = fontSize
        label.fontName = fontName
        label.position = position
        overlay.addChild(label)
    }
    
    private func showGameOver() {
        
        guard let camera = cameraHandler.node else { return }
        
        let (screenWidth, screenHeight, screenScale) = (
            UIScreen.main.nativeBounds.width,
            UIScreen.main.nativeBounds.height,
            UIScreen.main.nativeScale
        )
        
        let gameOverScreen = showOverlay(on: camera,
                                         width: screenWidth,
                                         height: screenHeight)
        
        addLabelOn(overlay: gameOverScreen,
                   text: "GAME OVER",
                   fontSize: 48,
                   position: CGPoint(x: 0, y: 400))
        
        let outOfBatteryLogo = SKSpriteNode(imageNamed: "gameovericon")
        outOfBatteryLogo.position = CGPoint(x: 0, y: 120)
        outOfBatteryLogo.setScale(screenScale)
        gameOverScreen.addChild(outOfBatteryLogo)
        
        addLabelOn(overlay: gameOverScreen,
                   text: "Your battery has died!",
                   fontSize: 36,
                   position: CGPoint(x: 0, y: -120))
        
        let exitButton = SpriteButton(imageName: "exit",
                                      buttonName: "exit")
        exitButton.delegate = self
        exitButton.position = CGPoint(x: -112, y: -440)
        exitButton.setScale(1.75)
        gameOverScreen.addChild(exitButton)
        
        let restartButton = SpriteButton(imageName: "restart",
                                         buttonName: "restart")
        restartButton.delegate = self
        restartButton.position = CGPoint(x: 112, y: -440)
        restartButton.setScale(1.75)
        gameOverScreen.addChild(restartButton)
    }
    
    func win() {
        gameStateHandler.currentState = .won
    }
    
    func pause() {
        gameStateHandler.currentState = .paused
        
        // remove / 'pause' currently ongoing actions
        gameStateHandler.delegate?.pauseTimer()
        energyBarHandler.delegate?.pauseUsingBattery()
        
        showPauseScreen()
    }
    
    private func showPauseScreen() {
        guard let camera = cameraHandler.node else { return }
               
        let (screenWidth, screenHeight) = (UIScreen.main.nativeBounds.width,
                                           UIScreen.main.nativeBounds.height)

        let pauseScreen = showOverlay(on: camera,
                                      width: screenWidth,
                                      height: screenHeight,
                                      isWhite: false,
                                      alpha: 1,
                                      overlayNodeName: "pauseScreen")
        
        // back button : "chevron.left" here
        let backButton = SpriteButton(uiImageSystemName: "chevron.left",
                                      buttonName: "pauseBack",
                                      tintColor: .white,
                                      size: CGSize(width: 48, height: 60))
        backButton.delegate = self
        backButton.position = CGPoint(x: -screenWidth / 2 + 100,
                                      y: screenHeight / 2 - 200)
        backButton.zPosition = 10
        pauseScreen.addChild(backButton)
        
        let mainMenuButton = LabelButton(
            text: "M A I N   M E N U",
            buttonName: "pauseMainMenu",
            fontSize: 54,
            fontColor: .white)
        
        mainMenuButton.delegate = self
        mainMenuButton.position = CGPoint(x: 0, y: 64)
        pauseScreen.addChild(mainMenuButton)
        
        let restartButton = LabelButton(
            text: "R E S T A R T",
            buttonName: "pauseRestart",
            fontSize: 54,
            fontColor: .white)
        
        restartButton.delegate = self
        restartButton.position = CGPoint(x: 0, y: -64)
        pauseScreen.addChild(restartButton)
    }
    
    func resume() {
        guard let camera = cameraHandler.node else { return }
        
        gameStateHandler.currentState = .playing
        
        // remove / 'pause' currently ongoing actions
        gameStateHandler.delegate?.startTimer()
        
        let currentDischargeDuration = energyBarHandler.dischargeDuration
        energyBarHandler.delegate?.useBattery(for: currentDischargeDuration)
        
        let pauseScreen = camera.childNode(withName: "pauseScreen")
        pauseScreen?.removeAllChildren()
        pauseScreen?.removeFromParent()
    }
    
    func restart() {
        guard let view = self.view else { return }
        
        self.removeAllChildren()
        self.removeAllActions()
        
        print(self.size)
        let newGame = GameScene(size: self.size)
        newGame.scaleMode = .aspectFill
        view.presentScene(newGame)
    }
    
    func goToMainMenu() {
        guard let view = self.view else { return }
    
        if let mainMenu = MainMenuScene(fileNamed: "MainMenuScene") {
            mainMenu.scaleMode = .aspectFill
            view.presentScene(mainMenu)
        }
        
        view.ignoresSiblingOrder = true
    }
    
    func updateTimerDisplay() {
        guard !energyBarHandler.isDead else { return }
        guard let timerLabel = gameStateHandler.timerLabel else { return }
        let timeString = gameStateHandler.secondsElapsed.asTimeString(style: .positional)
        timerLabel.text = timeString
    }
    
    func onButtonTap(name buttonName: String) {
        switch buttonName {
        case "restart", "pauseRestart":
            restart()
        case "pause":
            pause()
        case "pauseBack":
            resume()
        case "exit", "pauseMainMenu":
            goToMainMenu()
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
