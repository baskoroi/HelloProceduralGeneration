//
//  IntroComicScene.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/15/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import AVFoundation
import SpriteKit

class IntroComicScene: SKScene, ButtonDelegate {
    func onButtonTap(name buttonName: String) {
        startGame()
    }
    
    let startButton = SpriteButton(imageName: "mainMenuStartButton",
                                   buttonName: "comicStartButton")
    
    override func didMove(to view: SKView) {
        setupBackgroundMusic()
        playBackgroundMusic()
        
        setupStartButton()
    }
    
    func setupStartButton() {
        startButton.delegate = self
        startButton.position = CGPoint(x: 0, y: 0)
        startButton.setScale(2.5)
        startButton.zPosition = 0
        scene?.addChild(startButton)
    }
    
    func startGame() {
        // MARK: after that, start a new game
        guard let skView = self.view else { return }
        
        let scene = GameScene(size: UIScreen.main.nativeBounds.size)
        scene.scaleMode = .aspectFill
        
        let fadeToBlack = SKTransition.fade(withDuration: 0.75)
        skView.presentScene(scene, transition: fadeToBlack)
    }
    
    func setupBackgroundMusic() {
        let musicNode = SKAudioNode(fileNamed: "intro")
        musicNode.name = "comicBGM"
        musicNode.isPositional = false
        // musicNode's autoplay is true by default
        
        addChild(musicNode)
    }
    
    func playBackgroundMusic() {
        guard let musicNode = childNode(withName: "comicBGM") as? SKAudioNode
            , let musicAVNode = musicNode.avAudioNode
            , let musicEngine = musicAVNode.engine else { return }
        
        do {
            try musicEngine.start()
        } catch {
            fatalError("Background music failed to load")
        }
    }
    
    func stopBackgroundMusic() {
        guard let musicNode = childNode(withName: "comicBGM") as? SKAudioNode
            , let musicAVNode = musicNode.avAudioNode
            , let musicEngine = musicAVNode.engine else { return }
        
        musicEngine.stop()
    }
}
