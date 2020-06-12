//
//  GameScene+PlayerExtension.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/12/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

extension GameScene: PlayerDelegate {
    func setupPlayer() {
        playerHandler.node = SKSpriteNode(imageNamed: "PlayerFacingDown")
        
        self.addChild(playerHandler.node!)
        
        playerHandler.node!.name = "player"
        
        // place player on center of map
        // divide by 10, since zoom factor = 1/10 by default
        playerHandler.node!.position = CGPoint(x: 128 * 128 / zoomInFactor,
                                               y: 128 * 128 / zoomInFactor)
        playerHandler.node!.zPosition = 1
        
        setupPlayerPhysicsBody()
        setupPlayerAnimations()
    }

    func setupPlayerPhysicsBody() {
        guard let player = playerHandler.node else { return }
        
        player.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: playerHandler.size.width,
                                height: playerHandler.size.height)
        )
        player.physicsBody?.restitution = 0.4
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = TileCategory.player
        player.physicsBody?.contactTestBitMask =
            TileCategory.acid | TileCategory.boulder |
            TileCategory.energyCell | TileCategory.planeDebris |
            TileCategory.brokenRobots
        player.physicsBody?.collisionBitMask =
            TileCategory.boulder | TileCategory.planeDebris |
            TileCategory.brokenRobots
    }

    func setupPlayerAnimations() {
        // both standing & running
        playerHandler.facingDown = SKAction.run {
            self.playerHandler.node?.texture = PlayerAnimations.playerFacingDownTexture
        }
        
        // only standing
        playerHandler.standingUp = SKAction.run {
            self.playerHandler.node?.texture = PlayerAnimations.playerStandingUpTexture
        }
        playerHandler.standingLeft = SKAction.run {
            self.playerHandler.node?.texture = PlayerAnimations.playerStandingLeftTexture
        }
        playerHandler.standingRight = SKAction.run {
            self.playerHandler.node?.texture = PlayerAnimations.playerStandingRightTexture
        }
        
        // only running
        playerHandler.runningUp = SKAction.repeatForever(
            SKAction.animate(with: PlayerAnimations.playerRunningUpTextures,
                             timePerFrame: 0.1)
        )
        playerHandler.runningLeft = SKAction.repeatForever(
            SKAction.animate(with: PlayerAnimations.playerRunningLeftTextures,
                             timePerFrame: 0.1)
        )
        playerHandler.runningRight = SKAction.repeatForever(
            SKAction.animate(with: PlayerAnimations.playerRunningRightTextures,
                             timePerFrame: 0.1)
        )
        
        // by default, set player's idle animation to facing down
        // it doesn't have any movement speed in the start
        playerHandler.idleAfterMoveAction = playerHandler.facingDown
        standPlayerStill()
    }
    
    func movePlayer(to location: CGPoint) {
        guard let player        = playerHandler.node
            , let runningRight  = playerHandler.runningRight
            , let runningUp     = playerHandler.runningUp
            , let runningLeft   = playerHandler.runningLeft
            , let standingRight = playerHandler.standingRight
            , let standingUp    = playerHandler.standingUp
            , let standingLeft  = playerHandler.standingLeft
            , let facingDown    = playerHandler.facingDown
            , playerHandler.idleAfterMoveAction != nil else { return }
        
        let movingActionKey = PlayerAnimations.ActionKeys.moving.rawValue
        
        // remove previously moveToAction that's still existing, if any
        player.removeAllActions()
        
        let dx = location.x - player.position.x
        let dy = location.y - player.position.y
        
        let angle = atan2(dy, dx)
        let quarterRadian = CGFloat.pi / 4
        
        let speed: CGFloat = 540 // move 500 screen points every second
        
        let movePlayerAction: SKAction
        let animatePlayerAction: SKAction
        
        // due to the visual nature of the game, only 4-way controls are allowed
        // player needs to hold screen in order to keep moving
        switch angle {
        case (-quarterRadian) ..< quarterRadian: // right
            animatePlayerAction = runningRight
            playerHandler.idleAfterMoveAction = standingRight
            
            movePlayerAction = SKAction.repeatForever(
                SKAction.moveBy(x: speed, y: 0, duration: 1))
            
        case quarterRadian ..< 3 * quarterRadian: // up
            animatePlayerAction = runningUp
            playerHandler.idleAfterMoveAction = standingUp
            
            movePlayerAction = SKAction.repeatForever(
                SKAction.moveBy(x: 0, y: speed, duration: 1))
            
        case 3 * quarterRadian ..< CGFloat.pi,
             -CGFloat.pi ..< -3 * quarterRadian: // left
            animatePlayerAction = runningLeft
            playerHandler.idleAfterMoveAction = standingLeft
            
            movePlayerAction = SKAction.repeatForever(
                SKAction.moveBy(x: -speed, y: 0, duration: 1))
            
        default: // down
            animatePlayerAction = facingDown
            playerHandler.idleAfterMoveAction = facingDown
            
            movePlayerAction = SKAction.repeatForever(
                SKAction.moveBy(x: 0, y: -speed, duration: 1))
        }

        let moveActionGroup = SKAction.group([movePlayerAction, animatePlayerAction])
        player.run(moveActionGroup, withKey: movingActionKey)
    }

}
