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
    
    // facing down applies for both running and standing,
    // since the gas animation below is "behind" robot's body
    static let playerFacingDownTexture: SKTexture =
        SKTexture(imageNamed: "PlayerFacingDown")
    
    // standing: no animation
    static let playerStandingLeftTexture: SKTexture =
        SKTexture(imageNamed: "PlayerStandingLeft")
    static let playerStandingRightTexture: SKTexture =
        SKTexture(imageNamed: "PlayerStandingRight")
    static let playerStandingUpTexture: SKTexture =
        SKTexture(imageNamed: "PlayerStandingUp")
    
    static let playerRunningUpTextures: [SKTexture] = [
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
    
    static let playerRunningLeftTextures: [SKTexture] = [
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
    
    static let playerRunningRightTextures: [SKTexture] = [
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
    
    
    
}
