//
//  MainMenuScene.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/15/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import AVFoundation
import SpriteKit

class MainMenuScene: SKScene, ButtonDelegate {
        
    func onButtonTap(name buttonName: String) {
        switch buttonName {
        case "mainMenuStartButton":
            startComic()
        default:
            break
        }
    }
    
    let startButton = SpriteButton(imageName: "mainMenuStartButton",
                                   buttonName: "mainMenuStartButton")
    
    override func didMove(to view: SKView) {
        self.size = UIScreen.main.nativeBounds.size
        
        setupStartButton()
        setupBackgroundMusic()
        playBackgroundMusic()
    }
    
    func setupStartButton() {
        startButton.delegate = self
        startButton.position = CGPoint(x: 0, y: -200)
        startButton.zPosition = 5
        childNode(withName: "mainMenuScreen")?.addChild(startButton)
    }
    
    func startComic() {
        guard let view = self.view else { return }
        
        let fade = SKTransition.fade(withDuration: 0.75)
        
        if let comic = IntroComicScene(fileNamed: "IntroComicScene") {
            comic.scaleMode = .aspectFill
            view.presentScene(comic, transition: fade)
        }
        
        view.ignoresSiblingOrder = true
    }
    
    func startGame() {
        // MARK: after that, start a new game
        guard let skView = self.view else { return }
        
        let scene = GameScene(size: UIScreen.main.nativeBounds.size)
        scene.scaleMode = .aspectFill
        
        let fadeToBlack = SKTransition.fade(with: .black, duration: 2)
        skView.presentScene(scene, transition: fadeToBlack)
    }
    
    func setupBackgroundMusic() {
        let musicNode = SKAudioNode(fileNamed: "intro")
        musicNode.name = "mainMenuBGM"
        musicNode.isPositional = false
        // musicNode's autoplay is true by default
        
        addChild(musicNode)
    }
    
    func playBackgroundMusic() {
        guard let musicNode = childNode(withName: "mainMenuBGM") as? SKAudioNode
            , let musicAVNode = musicNode.avAudioNode
            , let musicEngine = musicAVNode.engine else { return }
        
        do {
            try musicEngine.start()
        } catch {
            fatalError("Background music failed to load")
        }
    }
    
    func stopBackgroundMusic() {
        guard let musicNode = childNode(withName: "mainMenuBGM") as? SKAudioNode
            , let musicAVNode = musicNode.avAudioNode
            , let musicEngine = musicAVNode.engine else { return }
        
        musicEngine.stop()
    }
}
