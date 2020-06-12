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
    
//    var cam: SKCameraNode?
    let zoomInFactor: CGFloat = 14
    
    var player: SKSpriteNode?
    var playerSize = CGSize(width: 128, height: 128)
    var playerFacingDown: SKAction? // for both running + standing
    var playerStandingUp: SKAction?
    var playerStandingLeft: SKAction?
    var playerStandingRight: SKAction?
    var playerRunningUp: SKAction?
    var playerRunningLeft: SKAction?
    var playerRunningRight: SKAction?
    var idleAfterMoveAction: SKAction?
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    override func didMove(to view: SKView) {
        mapHandler.delegate = self
        mapHandler.setup()
        
        cameraHandler.delegate = self
        setupCamera()
        setupPlayer()
    }
    
    // MARK: - player animations, behavior, etc.
    func setupPlayer() {
        player = SKSpriteNode(imageNamed: "PlayerFacingDown")
        
        self.addChild(player!)
        
        player!.name = "player"
        
        // place player on center of map
        // divide by 10, since zoom factor = 1/10 by default
        player!.position = CGPoint(x: 128 * 128 / zoomInFactor, y: 128 * 128 / zoomInFactor)
        player!.zPosition = 1
        
        setupPlayerPhysicsBody()
        setupPlayerAnimations()
    }
    
    private func setupPlayerPhysicsBody() {
        guard let player = player else { return }
        
        player.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: playerSize.width,
                                height: playerSize.height)
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
    
    private func setupPlayerAnimations() {
        // both standing & running
        playerFacingDown = SKAction.run {
            self.player?.texture = PlayerAnimations.playerFacingDownTexture
        }
        
        // only standing
        playerStandingUp = SKAction.run {
            self.player?.texture = PlayerAnimations.playerStandingUpTexture
        }
        playerStandingLeft = SKAction.run {
            self.player?.texture = PlayerAnimations.playerStandingLeftTexture
        }
        playerStandingRight = SKAction.run {
            self.player?.texture = PlayerAnimations.playerStandingRightTexture
        }
        
        // only running
        playerRunningUp = SKAction.repeatForever(
            SKAction.animate(with: PlayerAnimations.playerRunningUpTextures,
                             timePerFrame: 0.1)
        )
        playerRunningLeft = SKAction.repeatForever(
            SKAction.animate(with: PlayerAnimations.playerRunningLeftTextures,
                             timePerFrame: 0.1)
        )
        playerRunningRight = SKAction.repeatForever(
            SKAction.animate(with: PlayerAnimations.playerRunningRightTextures,
                             timePerFrame: 0.1)
        )
        
        // by default, set player's idle animation to facing down
        // it doesn't have any movement speed in the start
        idleAfterMoveAction = playerFacingDown
        standPlayerStill()
    }
    
    private func movePlayer(to location: CGPoint) {
        guard let player = player
            , let playerRunningRight = playerRunningRight
            , let playerRunningUp = playerRunningUp
            , let playerRunningLeft = playerRunningLeft
            , let playerStandingRight = playerStandingRight
            , let playerStandingUp = playerStandingUp
            , let playerStandingLeft = playerStandingLeft
            , let playerFacingDown = playerFacingDown
            , idleAfterMoveAction != nil else { return }
        
        let movingActionKey = PlayerAnimations.ActionKeys.moving.rawValue
        
        // remove previously moveToAction that's still existing, if any
        player.removeAllActions()
        
        let dx = location.x - player.position.x
        let dy = location.y - player.position.y
        
        let angle = atan2(dy, dx)
        let quarterRadian = CGFloat.pi / 4
        
//        let moveDuration: TimeInterval
        let speed: CGFloat = 540 // move 500 screen points every second
        
        let movePlayerAction: SKAction
        let animatePlayerAction: SKAction
        
        // due to the visual nature of the game, only 4-way controls are allowed
        // player needs to hold screen in order to keep moving
        switch angle {
        case (-quarterRadian) ..< quarterRadian: // right
            animatePlayerAction = playerRunningRight
            idleAfterMoveAction = playerStandingRight
            
            movePlayerAction = SKAction.repeatForever(SKAction.moveBy(x: speed, y: 0, duration: 1))
            
        case quarterRadian ..< 3 * quarterRadian: // up
            animatePlayerAction = playerRunningUp
            idleAfterMoveAction = playerStandingUp
            
            movePlayerAction = SKAction.repeatForever(SKAction.moveBy(x: 0, y: speed, duration: 1))
            
        case 3 * quarterRadian ..< CGFloat.pi, -CGFloat.pi ..< -3 * quarterRadian: // left
            animatePlayerAction = playerRunningLeft
            idleAfterMoveAction = playerStandingLeft
            
            movePlayerAction = SKAction.repeatForever(SKAction.moveBy(x: -speed, y: 0, duration: 1))
        default: // down
            animatePlayerAction = playerFacingDown
            idleAfterMoveAction = playerFacingDown
            
            movePlayerAction = SKAction.repeatForever(SKAction.moveBy(x: 0, y: -speed, duration: 1))
        }

        let moveActionGroup = SKAction.group([movePlayerAction, animatePlayerAction])
        player.run(moveActionGroup, withKey: movingActionKey)
    }

    // MARK: - scene camera
//    func setupCamera() {
//        cam = SKCameraNode()
//        self.camera = cam
//        self.addChild(cam!)
//        let zoomInAction = SKAction.scale(to: CGFloat(1) / zoomInFactor, duration: 1)
//        cam!.run(zoomInAction)
//    }
    
//    private func generatePerlinNoiseMap(columns: Int, rows: Int) -> GKNoiseMap {
//        let source = GKPerlinNoiseSource()
//        source.persistence = 0.9
//        
//        let noise = GKNoise(source)
//        let size = vector2(1.0, 1.0)
//        let origin = vector2(0.0, 0.0)
//        let sampleCount = vector2(Int32(columns), Int32(rows))
//        
//        return GKNoiseMap(noise, size: size, origin: origin,
//                          sampleCount: sampleCount, seamless: true)
//    }
//    
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
    
    private func standPlayerStill() {
        guard let player = player
            , let idleAfterMoveAction = idleAfterMoveAction else { return }
        player.removeAction(forKey: PlayerAnimations.ActionKeys.moving.rawValue)
        player.run(idleAfterMoveAction, withKey: PlayerAnimations.ActionKeys.standing.rawValue)
    }
    
    // MARK: - camera tracking
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        if let camera = cameraHandler.node, let player = player {
            camera.position = player.position
        }
    }
}
