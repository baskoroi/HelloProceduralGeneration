//
//  MainMenuScene.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/15/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene, ButtonDelegate {
    func onButtonTap(name buttonName: String) {
        switch buttonName {
        case "mainMenuStartButton":
            startGame()
        default:
            break
        }
    }
    
    let startButton = SpriteButton(imageName: "mainMenuStartButton",
                                   buttonName: "mainMenuStartButton")
    
    override func didMove(to view: SKView) {
        self.size = UIScreen.main.nativeBounds.size
        
        startButton.delegate = self
        startButton.position = CGPoint(x: 0, y: -200)
        startButton.zPosition = 5
        childNode(withName: "mainMenuScreen")?.addChild(startButton)
    }
    
    func startComic() {
        
    }
    
    func startGame() {
        // if first time playing - show the comic first!
        
        // else if already played second time - directly start a new game
        guard let skView = self.view else {
            print("Could not get SKview")
            return
        }
        
        let scene = GameScene(size: UIScreen.main.nativeBounds.size)
        scene.scaleMode = .aspectFill
        
        let fadeToBlack = SKTransition.fade(with: .black, duration: 2)
        skView.presentScene(scene, transition: fadeToBlack)
    }
}
