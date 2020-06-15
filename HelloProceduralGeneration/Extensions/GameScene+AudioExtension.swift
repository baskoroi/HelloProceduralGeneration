//
//  GameScene+AudioExtension.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/15/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

extension GameScene {
    func setupAllSounds() {
        setupBackgroundMusic()
        playBackgroundMusic()
    }
    
    // MARK: - background music
    
    func setupBackgroundMusic() {
        let musicNode = SKAudioNode(fileNamed: "BGM1(low)")
        musicNode.name = "gameBGM"
        musicNode.isPositional = false
        // musicNode's autoplay is true by default
        
        addChild(musicNode)
    }
    
    func playBackgroundMusic() {
        guard let musicNode = childNode(withName: "gameBGM") as? SKAudioNode
            , let musicAVNode = musicNode.avAudioNode
            , let musicEngine = musicAVNode.engine else { return }
        
        do {
            try musicEngine.start()
        } catch {
            fatalError("Background music in game failed to load")
        }
    }
    
    func stopBackgroundMusic() {
        guard let musicNode = childNode(withName: "gameBGM") as? SKAudioNode
            , let musicAVNode = musicNode.avAudioNode
            , let musicEngine = musicAVNode.engine else { return }
        
        musicEngine.stop()
    }
}
