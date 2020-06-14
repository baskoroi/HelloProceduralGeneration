//
//  GameScene.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/10/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
        
    var mapHandler = MapHandler()
    var cameraHandler = CameraHandler(zoomInFactor: 14)
    var playerHandler = PlayerHandler()
    var energyBarHandler = EnergyBarHandler()
    var gameStateHandler = GameStateHandler()
    
    let zoomInFactor: CGFloat = 14
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        mapHandler.delegate = self
        mapHandler.setup()
        
        playerHandler.delegate = self
        playerHandler.setup()
        
        cameraHandler.delegate = self
        cameraHandler.setup()
        
        energyBarHandler.delegate = self
        energyBarHandler.setup()
        
        gameStateHandler.delegate = self
        gameStateHandler.setup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let destination = touch.location(in: self)
        movePlayer(to: destination)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        standPlayerStill()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        if let camera = cameraHandler.node, let player = playerHandler.sprite {
            camera.position = player.position
            print(player.position)
        }
    }
}
