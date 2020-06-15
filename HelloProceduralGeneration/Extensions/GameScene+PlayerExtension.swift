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
        playerHandler.sprite = SKSpriteNode(imageNamed: "PlayerStandingDown")
        guard let player = playerHandler.sprite else { return }
        
        self.addChild(player)
        
        player.name = "player"
        
        // place player on center of map
        // divide by 10, since zoom factor = 1/10 by default
        player.position = CGPoint(x: 0, y: 0)
        player.zPosition = 1
        
        setupPlayerPhysicsBody()
        setupPlayerAnimations()
        
        playerHandler.movingSoundAction = SKAction.repeatForever(
            SKAction.playSoundFileNamed("rolling.mp3",
                                        waitForCompletion: false))
    }

    func setupPlayerPhysicsBody() {
        guard let player = playerHandler.sprite else { return }
        
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
        // only standing
        playerHandler.standingUp = SKAction.run {
            self.playerHandler.sprite?.texture =
                PlayerAnimations.Textures.Standing.up
        }
        playerHandler.standingDown = SKAction.run {
            self.playerHandler.sprite?.texture =
                PlayerAnimations.Textures.Standing.down
        }
        playerHandler.standingLeft = SKAction.run {
            self.playerHandler.sprite?.texture =
                PlayerAnimations.Textures.Standing.left
        }
        playerHandler.standingRight = SKAction.run {
            self.playerHandler.sprite?.texture =
                PlayerAnimations.Textures.Standing.right
        }
        
        // only running
        playerHandler.runningUp = SKAction.repeatForever(
            SKAction.animate(with: PlayerAnimations.Textures.Running.up,
                             timePerFrame: 0.1)
        )
        playerHandler.runningLeft = SKAction.repeatForever(
            SKAction.animate(with: PlayerAnimations.Textures.Running.left,
                             timePerFrame: 0.1)
        )
        playerHandler.runningRight = SKAction.repeatForever(
            SKAction.animate(with: PlayerAnimations.Textures.Running.right,
                             timePerFrame: 0.1)
        )
        playerHandler.runningDown = SKAction.repeatForever(
            SKAction.animate(with: PlayerAnimations.Textures.Running.down,
                             timePerFrame: 0.1)
        )
        
        // by default, set player's idle animation to facing down
        // it doesn't have any movement speed in the start
        playerHandler.idleAfterMoveAction = playerHandler.standingDown
        standPlayerStill()
    }
    
    func standPlayerStill() {
        guard let player = playerHandler.sprite
            , let idleAfterMoveAction = playerHandler.idleAfterMoveAction else { return }
        player.removeAction(forKey: PlayerAnimations.ActionKeys.moving.rawValue)
        player.run(idleAfterMoveAction, withKey: PlayerAnimations.ActionKeys.standing.rawValue)
    }
    
    func movePlayer(to location: CGPoint) {
        guard gameStateHandler.currentState != .paused else { return }
        
        guard !energyBarHandler.isDead else {
            playerHandler.sprite?.removeAllActions()
            return
        }
        
        guard let player        = playerHandler.sprite
            , let runningUp     = playerHandler.runningUp
            , let runningDown   = playerHandler.runningDown
            , let runningLeft   = playerHandler.runningLeft
            , let runningRight  = playerHandler.runningRight
            , let standingUp    = playerHandler.standingUp
            , let standingDown  = playerHandler.standingDown
            , let standingLeft  = playerHandler.standingLeft
            , let standingRight = playerHandler.standingRight
            , playerHandler.idleAfterMoveAction != nil else { return }
        
        let movingActionKey = PlayerAnimations.ActionKeys.moving.rawValue
        
        // remove previously moveToAction that's still existing, if any
        player.removeAllActions()
        
        let dx = location.x - player.position.x
        let dy = location.y - player.position.y
        
        let angle = atan2(dy, dx)
        let radian = CGFloat.pi // 1 rad = 180°
        
        let speed: CGFloat = 540 // move 500 screen points every second
        
        let movePlayerAction: SKAction
        let animatePlayerAction: SKAction
        
        // due to the visual nature of the game, only 4-way controls are allowed
        // player needs to hold screen in order to keep moving
        switch angle {
        case (-radian / 4) ..< radian / 4: // right
            animatePlayerAction = runningRight
            playerHandler.idleAfterMoveAction = standingRight
            
            movePlayerAction = SKAction.repeatForever(
                SKAction.moveBy(x: speed, y: 0, duration: 1))
            
        case radian / 4 ..< 3 * radian / 4: // up
            animatePlayerAction = runningUp
            playerHandler.idleAfterMoveAction = standingUp
            
            movePlayerAction = SKAction.repeatForever(
                SKAction.moveBy(x: 0, y: speed, duration: 1))
            
        case 3 * radian / 4 ..< CGFloat.pi,
             -CGFloat.pi ..< -3 * radian / 4: // left
            animatePlayerAction = runningLeft
            playerHandler.idleAfterMoveAction = standingLeft
            
            movePlayerAction = SKAction.repeatForever(
                SKAction.moveBy(x: -speed, y: 0, duration: 1))
            
        default: // down
            animatePlayerAction = runningDown
            playerHandler.idleAfterMoveAction = standingDown
            
            movePlayerAction = SKAction.repeatForever(
                SKAction.moveBy(x: 0, y: -speed, duration: 1))
        }
        
        let moveActionGroup = SKAction.group([movePlayerAction,
                                              animatePlayerAction])
        player.run(moveActionGroup, withKey: movingActionKey)
    }

}
