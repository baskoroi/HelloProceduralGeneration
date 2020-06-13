//
//  PlayerAnimations.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/11/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

struct PlayerAnimations {
    
    enum ActionKeys: String {
        case moving = "moving"
        case standing = "standing"
    }

    struct Textures {
        struct Standing {
            static let left = SKTexture(imageNamed: "PlayerStandingLeft")
            static let right = SKTexture(imageNamed: "PlayerStandingRight")
            static let up = SKTexture(imageNamed: "PlayerStandingUp")
            static let down = SKTexture(imageNamed: "PlayerStandingDown")
        }
        struct Running {
            static let left: [SKTexture] = [
                SKTexture(imageNamed: "PlayerRunningLeft1"),
                SKTexture(imageNamed: "PlayerRunningLeft2"),
                SKTexture(imageNamed: "PlayerRunningLeft3"),
                SKTexture(imageNamed: "PlayerRunningLeft4"),
                SKTexture(imageNamed: "PlayerRunningLeft5"),
                SKTexture(imageNamed: "PlayerRunningLeft6"),
                SKTexture(imageNamed: "PlayerRunningLeft7"),
                SKTexture(imageNamed: "PlayerRunningLeft8"),
                SKTexture(imageNamed: "PlayerRunningLeft9"),
                SKTexture(imageNamed: "PlayerRunningLeft10"),
            ]
            
            static let right: [SKTexture] = [
                SKTexture(imageNamed: "PlayerRunningRight1"),
                SKTexture(imageNamed: "PlayerRunningRight2"),
                SKTexture(imageNamed: "PlayerRunningRight3"),
                SKTexture(imageNamed: "PlayerRunningRight4"),
                SKTexture(imageNamed: "PlayerRunningRight5"),
                SKTexture(imageNamed: "PlayerRunningRight6"),
                SKTexture(imageNamed: "PlayerRunningRight7"),
                SKTexture(imageNamed: "PlayerRunningRight8"),
                SKTexture(imageNamed: "PlayerRunningRight9"),
                SKTexture(imageNamed: "PlayerRunningRight10"),
            ]
            
            static let up = [
                SKTexture(imageNamed: "PlayerRunningUp1"),
                SKTexture(imageNamed: "PlayerRunningUp2"),
                SKTexture(imageNamed: "PlayerRunningUp3"),
                SKTexture(imageNamed: "PlayerRunningUp4"),
                SKTexture(imageNamed: "PlayerRunningUp5"),
                SKTexture(imageNamed: "PlayerRunningUp6"),
                SKTexture(imageNamed: "PlayerRunningUp7"),
                SKTexture(imageNamed: "PlayerRunningUp8"),
                SKTexture(imageNamed: "PlayerRunningUp9"),
                SKTexture(imageNamed: "PlayerRunningUp10"),
            ]
            
            static let down = [
                SKTexture(imageNamed: "PlayerRunningDown1"),
                SKTexture(imageNamed: "PlayerRunningDown2"),
                SKTexture(imageNamed: "PlayerRunningDown3"),
                SKTexture(imageNamed: "PlayerRunningDown4"),
                SKTexture(imageNamed: "PlayerRunningDown5"),
                SKTexture(imageNamed: "PlayerRunningDown6"),
                SKTexture(imageNamed: "PlayerRunningDown7"),
                SKTexture(imageNamed: "PlayerRunningDown8"),
                SKTexture(imageNamed: "PlayerRunningDown9"),
                SKTexture(imageNamed: "PlayerRunningDown10"),
            ]
        }
    }
}
