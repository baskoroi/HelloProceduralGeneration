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
    static let planeScrap: TileContent      = 1 << 3
    static let robotScrap: TileContent      = 1 << 4
    static let energyCell: TileContent      = 1 << 5
    static let player: TileContent          = 1 << 6
}

class GameScene: SKScene {
    
    let mapNode = SKNode()
    var mapTilesContents = Array(
        repeating: Array(repeating: TileCategory.ground, count: 128),
        count: 128
    )
    
    var player: SKSpriteNode?
    var cam: SKCameraNode?
    
    let numTilesOnSide = 128
    
    let tileSize = CGSize(width: 128, height: 128)
    let (rows, columns) = (128, 128)
    let mapSize = CGSize(width: 128 * 128, height: 128 * 128)
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    override func didMove(to view: SKView) {
        setupMap()
        setupPlayer()
        setupCamera()
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
        
        // MARK: generate boulders using Poisson Disc Sampling algorithm
        let boulderDistanceRadius = 4*(2.squareRoot())
        generateBoulders(radius: boulderDistanceRadius,
                         tileSet: tileSet,
                         tileToSkip: TileCategory.acid)
        
        // enlarge scene to contain entire generated map
        scene?.size = mapSize
        // set up the physics
//        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
    }
    
    private func setupLandTiles(tileSet: SKTileSet) {
        let landTiles = tileSet.tileGroups.first { $0.name == "Land" }
        let bottomLayer = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        bottomLayer.fill(with: landTiles)
        mapNode.addChild(bottomLayer)
    }
    
    private func generateAcidSeas(tileSet: SKTileSet, fallbackTileGroup: SKTileGroup) {
        let acidTiles = tileSet.tileGroups.first { $0.name == "Acid" }
        let noiseMap = makeNoiseMap(columns: columns, rows: rows)
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
    
    private func checkWithin5x5Cluster(for tileToCheck: TileContent,
                                       column: Int, row: Int,
                                       maxColumnIndex: Int, maxRowIndex: Int) -> Bool {
        // set cluster bounds
        let minCol = max(0, column - 2)
        let maxCol = min(maxColumnIndex, column + 2)
        let minRow = max(0, row - 2)
        let maxRow = min(maxRowIndex, row + 2)

        for col in minCol...maxCol {
            for row in minRow...maxRow {
                if mapTilesContents[col][row] == tileToCheck {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func generateBoulders(radius: simd_double1,
                                  tileSet: SKTileSet,
                                  tileToSkip: TileContent) {
        let boulderLayer = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        boulderLayer.enableAutomapping = true
        mapNode.addChild(boulderLayer)
        
        let boulderTiles = tileSet.tileGroups.first { $0.name == "Boulder" }
        
        let boulderPoints = PoissonDiscSampling.generatePoints(radius: radius, sampleRegionSize: vector2(128,128))
        print("Boulders' count: \(boulderPoints.count)")
        
        for point in boulderPoints {
            let location = vector2(Int32(point.x), Int32(point.y))
            let (row, col) = (Int(location.y), Int(location.x))
            
            // some tiles cannot be placed boulders, such as acid
            if checkWithin5x5Cluster(for: tileToSkip,
                                     column: col,
                                     row: row,
                                     maxColumnIndex: numTilesOnSide - 1,
                                     maxRowIndex: numTilesOnSide - 1) {
                
                continue
            }
            
            boulderLayer.setTileGroup(boulderTiles, forColumn: col, row: row)
            mapTilesContents[col][row] = TileCategory.boulder
        }
    }
    
    func setupPlayer() {
        player = self.childNode(withName: "player") as? SKSpriteNode
        player!.physicsBody = SKPhysicsBody(circleOfRadius: player!.size.width / 2)
        player!.physicsBody?.allowsRotation = true
        player!.physicsBody?.restitution = 0.5
        player!.zPosition = 1
    }
    
    func setupCamera() {
        cam = SKCameraNode()
        self.camera = cam
        self.addChild(cam!)
        let zoomInAction = SKAction.scale(to: 1/10, duration: 10)
        cam!.run(zoomInAction)
    }
    
        // make map to determine water, stone, or grass tiles
    private func makeNoiseMap(columns: Int, rows: Int) -> GKNoiseMap {
        let source = GKPerlinNoiseSource()
        source.persistence = 0.9
        
        let noise = GKNoise(source)
        let size = vector2(1.0, 1.0)
        let origin = vector2(0.0, 0.0)
        let sampleCount = vector2(Int32(columns), Int32(rows))
        
        return GKNoiseMap(noise, size: size, origin: origin, sampleCount: sampleCount, seamless: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let moveToAction = SKAction.move(to: location, duration: 1)
        player!.run(moveToAction)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        if let camera = cam, let player = player {
          camera.position = player.position
        }
    }
}

extension CGSize{
    func getScaledSize(_ factor: CGFloat) -> CGSize {
        return CGSize(width: self.width, height: self.height)
    }
}
