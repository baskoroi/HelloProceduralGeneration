//
//  GameScene.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/10/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit
import GameplayKit

typealias TileContent = UInt32

struct TileCategory {
    static let ground: TileContent          = 1 << 0
    static let energyCellTaken: TileContent = 1 << 0
    static let boulder: TileContent         = 1 << 1
    static let acid: TileContent            = 1 << 2
    static let planeDebris: TileContent     = 1 << 3
    static let brokenRobots: TileContent    = 1 << 4
    static let energyCell: TileContent      = 1 << 5
    static let player: TileContent          = 1 << 6
}

class GameScene: SKScene {
    
    let mapNode = SKNode()
    var mapTilesContents = Array(
        repeating: Array(repeating: TileCategory.ground, count: 128),
        count: 128
    )
    
    var cam: SKCameraNode?
    var zoomInFactor: CGFloat = 10
    
    var player: SKSpriteNode?
    var playerFacingDown: SKAction? // for both running + standing
    var playerStandingUp: SKAction?
    var playerStandingLeft: SKAction?
    var playerStandingRight: SKAction?
    var playerRunningUp: SKAction?
    var playerRunningLeft: SKAction?
    var playerRunningRight: SKAction?
    var idleAfterMoveAction: SKAction?
    
    let numTilesOnSide = 128
    let tileLength = 128
    
    let tileSize = CGSize(width: 128, height: 128)
    let (rows, columns) = (128, 128)
    let mapSize = CGSize(width: 128 * 128, height: 128 * 128)
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    override func didMove(to view: SKView) {
        setupMap()
        setupCamera()
        setupPlayer()
    }
    
    func setupMap() {
        // add the map and "zoom out"
        addChild(mapNode)
        
        // retrieve tile sets from corresponding .sks files
        let tileSet = SKTileSet(named: "Proxima Tile Set")!
        
        // MARK: fill all tiles with land tiles, by default
        setupLandTiles(tileSet: tileSet)
        
        // MARK: generate acid seas using Perlin noise algorithm
        // boulders are allowed to overwrite acid seas
        let landTiles = tileSet.tileGroups.first { $0.name == "Land" }
        generateAcidSeas(tileSet: tileSet,
                         fallbackTileGroup: landTiles!)
        
        // create layer to insert items
        let itemsLayer = SKTileMapNode(tileSet: tileSet,
                                       columns: columns,
                                       rows: rows,
                                       tileSize: tileSize)
        itemsLayer.enableAutomapping = true
        mapNode.addChild(itemsLayer)
        
        // MARK: generate boulders around land (w/ Poisson Disc Sampling)
        distributeTilesAroundMap(radius: 4,
                                 layer: itemsLayer,
                                 tileSet: tileSet,
                                 tileGroupName: "Boulder",
                                 tileToAssign: TileCategory.boulder,
                                 tilesToSkip: [TileCategory.acid],
                                 enableCollision: true)
        
        // MARK: generate energy cells around land
        distributeTilesAroundMap(radius: 3 * 2.squareRoot(),
                                 layer: itemsLayer,
                                 tileSet: tileSet,
                                 tileGroupName: "Energy Cell",
                                 tileToAssign: TileCategory.energyCell,
                                 tilesToSkip: [TileCategory.acid,
                                               TileCategory.boulder])
        
        // MARK: generate broken robots around land
        distributeTilesAroundMap(radius: 5,
                                 layer: itemsLayer,
                                 tileSet: tileSet,
                                 tileGroupName: "Broken Robot",
                                 tileToAssign: TileCategory.brokenRobots,
                                 tilesToSkip: [TileCategory.acid,
                                               TileCategory.boulder,
                                               TileCategory.energyCell])
        
        // MARK: generate plane debris around land
        distributeTilesAroundMap(radius: 6,
                                 layer: itemsLayer,
                                 tileSet: tileSet,
                                 tileGroupName: "Plane Debris",
                                 tileToAssign: TileCategory.brokenRobots,
                                 tilesToSkip: [TileCategory.acid,
                                               TileCategory.boulder,
                                               TileCategory.energyCell,
                                               TileCategory.brokenRobots])
        
        // enlarge scene to contain entire generated map
        scene?.size = mapSize
        // set up the physics
    }
    
    private func setupLandTiles(tileSet: SKTileSet) {
        let landTiles = tileSet.tileGroups.first { $0.name == "Land" }
        let bottomLayer = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        bottomLayer.fill(with: landTiles)
        mapNode.addChild(bottomLayer)
    }
    
    private func generateAcidSeas(tileSet: SKTileSet, fallbackTileGroup: SKTileGroup) {
        let acidTiles = tileSet.tileGroups.first { $0.name == "Acid" }
        let noiseMap = generatePerlinNoiseMap(columns: columns, rows: rows)
        let topLayer = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        topLayer.enableAutomapping = true
        mapNode.addChild(topLayer)
        
        // set the tile, every column and every row
        for col in 0 ..< columns {
            for row in 0 ..< rows {
                // override boulder tiles - hence no validation
                
                let location = vector2(Int32(row), Int32(col))
                let terrainHeight = noiseMap.value(at: location)

                // increase terrainHeight to increase acid tile probability
                if terrainHeight < 0 {
                    
                    // set the tile to acid
                    topLayer.setTileGroup(acidTiles, forColumn: col, row: row)
                    mapTilesContents[col][row] = TileCategory.acid
                }
            }
        }
    }
    
    // generate tiles with even positional distribution using
    // Poisson Disc Sampling algorithm
    private func distributeTilesAroundMap(radius: simd_double1,
                                 layer: SKTileMapNode,
                                 tileSet: SKTileSet,
                                 tileGroupName: String,
                                 tileToAssign: TileContent,
                                 tilesToSkip: [TileContent],
                                 enableCollision: Bool = false) {
        
        let tiles = tileSet.tileGroups.first { $0.name == tileGroupName }
        
        let points = PoissonDiscSampling.generatePoints(radius: radius, sampleRegionSize: vector2(128,128))
        
        for point in points {
            let location = vector2(Int32(point.x), Int32(point.y))
            let (row, col) = (Int(location.y), Int(location.x))
            
            // some tiles cannot be placed above other tiles,
            // to avoid unintended overlaps
            // e.g. acid tiles cannot be placed close to surrounding boulder tiles
            if findTileWithin5x5Cluster(for: tilesToSkip,
                                        column: col,
                                        row: row,
                                        maxColumnIndex: numTilesOnSide - 1,
                                        maxRowIndex: numTilesOnSide - 1) {
                
                continue
            }
            
            layer.setTileGroup(tiles, forColumn: col, row: row)
            mapTilesContents[col][row] = tileToAssign
            
//            if enableCollision {
//                let x = CGFloat(col) * tileSize.width
//                let y = CGFloat(row) * tileSize.height
//            }
        }
    }
    
    private func findTileWithin5x5Cluster(for tilesToCheck: [TileContent],
                                          column: Int,
                                          row: Int,
                                          maxColumnIndex: Int,
                                          maxRowIndex: Int) -> Bool {
        
        // set cluster bounds
        let minCol = max(0, column - 2)
        let maxCol = min(maxColumnIndex, column + 2)
        let minRow = max(0, row - 2)
        let maxRow = min(maxRowIndex, row + 2)

        for col in minCol...maxCol {
            for row in minRow...maxRow {
                if tilesToCheck.contains(mapTilesContents[col][row]) {
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: - player animations, behavior, etc.
    func setupPlayer() {
//        player = self.childNode(withName: "player") as? SKSpriteNode
        
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
            rectangleOf: CGSize(width: player.size.width,
                                height: player.size.height)
        )
        player.physicsBody?.restitution = 0.4
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
    
    // MARK: - scene camera
    func setupCamera() {
        cam = SKCameraNode()
        self.camera = cam
        self.addChild(cam!)
        let zoomInAction = SKAction.scale(to: CGFloat(1) / zoomInFactor, duration: 1)
        cam!.run(zoomInAction)
    }
    
    private func generatePerlinNoiseMap(columns: Int, rows: Int) -> GKNoiseMap {
        let source = GKPerlinNoiseSource()
        source.persistence = 0.9
        
        let noise = GKNoise(source)
        let size = vector2(1.0, 1.0)
        let origin = vector2(0.0, 0.0)
        let sampleCount = vector2(Int32(columns), Int32(rows))
        
        return GKNoiseMap(noise, size: size, origin: origin,
                          sampleCount: sampleCount, seamless: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let destination = touch.location(in: self)
        movePlayer(to: destination)
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
        let speed: CGFloat = 500 // move 500 screen points every second
        
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
        
//        let
        let moveActionGroup = SKAction.group([movePlayerAction, animatePlayerAction])
        player.run(moveActionGroup, withKey: movingActionKey)
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
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        if let camera = cam, let player = player {
            camera.position = player.position
        }
    }
}

extension CGSize {
    func getScaledSize(_ factor: CGFloat) -> CGSize {
        return CGSize(width: self.width, height: self.height)
    }
}
