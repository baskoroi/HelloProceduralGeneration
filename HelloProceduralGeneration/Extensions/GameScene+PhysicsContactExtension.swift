//
//  GameScene+PhysicsContactExtension.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/12/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    }
}
