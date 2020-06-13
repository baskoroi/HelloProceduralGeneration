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
    
    let zoomInFactor: CGFloat = 14
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        mapHandler.delegate = self
        mapHandler.setup()
        
        cameraHandler.delegate = self
        cameraHandler.setup()
        
        playerHandler.delegate = self
        playerHandler.setup()
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
    
    func standPlayerStill() {
        guard let player = playerHandler.node
            , let idleAfterMoveAction = playerHandler.idleAfterMoveAction else { return }
        player.removeAction(forKey: PlayerAnimations.ActionKeys.moving.rawValue)
        player.run(idleAfterMoveAction, withKey: PlayerAnimations.ActionKeys.standing.rawValue)
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        if let camera = cameraHandler.node, let player = playerHandler.node {
            camera.position = player.position
        }
    }
}
