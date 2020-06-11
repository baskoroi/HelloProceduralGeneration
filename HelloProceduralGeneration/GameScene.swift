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
    
    let map = SKNode()
    var player : SKSpriteNode?
    var cam: SKCameraNode?
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    
    
    override func didMove(to view: SKView) {
        setupMap()
        setupPlayer()
        setupCamera()
    }
    
    func setupMap() {
        // add the map and "zoom out"
        addChild(map)
        
       
        // retrieve tile set from corresponding .sks file
        let tileSet = SKTileSet(named: "Sample Grid Tile Set")!
        let tileSize = CGSize(width: 128, height: 128)
        let (rows, columns) = (128, 128)
        
        let proximaTileSet = SKTileSet(named: "Proxima Tile Set")!
        // set tiles
        let waterTiles = tileSet.tileGroups.first { $0.name == "Water"        }
        let grassTiles = tileSet.tileGroups.first { $0.name == "Grass"        }
        let boulderTiles = proximaTileSet.tileGroups.first { $0.name == "Boulder"  }
        
        // set default tile = sand tile
        let bottomLayer = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        bottomLayer.fill(with: grassTiles)
        map.addChild(bottomLayer)
        
       
        
        // procedural generation using Perlin noise
        let noiseMap = makeNoiseMap(columns: columns, rows: rows)
        let topLayer = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        topLayer.enableAutomapping = true
        map.addChild(topLayer)
        
        // set the tile, every column and every row
        for column in 0 ..< columns {
            for row in 0 ..< rows {
                let location = vector2(Int32(row), Int32(column))
                let terrainHeight = noiseMap.value(at: location)

                if terrainHeight < 0 {
                    topLayer.setTileGroup(waterTiles, forColumn: column, row: row)
                    topLayer.tileDefinition(atColumn: column, row: row)?.name = "acid"
                } else {
                    topLayer.tileDefinition(atColumn: column, row: row)?.name = "land"
                }
                
            }
        }
        
        scene?.size = bottomLayer.mapSize
        // set up the physics
//        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        let boulderPoints = PoissonDiscSampling.generatePoints(radius: 2*(2.squareRoot()), sampleRegionSize: vector2(128,128))
        
      
        let boulderLayer = SKTileMapNode(tileSet: proximaTileSet, columns: columns, rows: rows, tileSize: tileSize.getScaledSize(4))
        boulderLayer.enableAutomapping = true
        map.addChild(boulderLayer)
        
        
        for point in boulderPoints {
            let location = vector2(Int32(point.x), Int32(point.y))
            let (row, column) = (Int(location.y), Int(location.x))
            let currentTile = topLayer.tileDefinition(atColumn: column, row: row)
            if let tile = currentTile{
                if tile.name != "acid" {
                   boulderLayer.setTileGroup(boulderTiles, forColumn: column, row: row)
                   boulderLayer.tileDefinition(atColumn: column, row: row)?.name = "acid"
                }
            }
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
        let zoomInAction = SKAction.scale(to: 1/10, duration: 1)
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
        guard let touch = touches.first else {return}
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
