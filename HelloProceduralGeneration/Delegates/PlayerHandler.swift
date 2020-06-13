//
//  PlayerHandler.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/12/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

protocol PlayerDelegate: class {
    func setupPlayer()
    func setupPlayerPhysicsBody()
    func setupPlayerAnimations()
    func movePlayer(to location: CGPoint)
}

class PlayerHandler {
    
    weak var delegate: PlayerDelegate?
    
    var node: SKSpriteNode?
    var size = CGSize(width: 128, height: 128)
    
    var standingUp: SKAction?
    var standingLeft: SKAction?
    var standingRight: SKAction?
    var standingDown: SKAction?
    
    var runningUp: SKAction?
    var runningLeft: SKAction?
    var runningRight: SKAction?
    var runningDown: SKAction?
    
    var idleAfterMoveAction: SKAction?
    
    func setup() {
        self.delegate?.setupPlayer()
    }
}
