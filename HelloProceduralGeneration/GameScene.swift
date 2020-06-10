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
    let player = SKSpriteNode(imageNamed: "player")
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    override func didMove(to view: SKView) {
        setupMap()
        setupPlayer()
    }
    
    func setupMap() {
        // add the map and "zoom out of it 2x"
        addChild(map)
        map.xScale = 0.5
        map.yScale = 0.5
        
        // retrieve tile set from corresponding .sks file
        let tileSet = SKTileSet(named: "Sample Grid Tile Set")!
        let tileSize = CGSize(width: 128, height: 128)
        let (rows, columns) = (128, 128)
        
        // set tiles
        let waterTiles = tileSet.tileGroups.first { $0.name == "Water"        }
        let grassTiles = tileSet.tileGroups.first { $0.name == "Grass"        }
        let sandTiles  = tileSet.tileGroups.first { $0.name == "Sand"         }
        let stoneTiles = tileSet.tileGroups.first { $0.name == "Cobblestone"  }
        
        // set default tile = sand tile
        let bottomLayer = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        bottomLayer.fill(with: sandTiles)
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
                } else if terrainHeight > 0.9 {
                    topLayer.setTileGroup(stoneTiles, forColumn: column, row: row)
                } else {
                    topLayer.setTileGroup(grassTiles, forColumn: column, row: row)
                }
            }
        }
    }
    
    func setupPlayer() {
        addChild(player)
        player.setScale(2)
    }
    
    // make map to determine water, stone, or grass tiles
    private func makeNoiseMap(columns: Int, rows: Int) -> GKNoiseMap {
        let source = GKPerlinNoiseSource()
        source.persistence = 0.95
        
        let noise = GKNoise(source)
        let size = vector2(1.0, 1.0)
        let origin = vector2(0.0, 0.0)
        let sampleCount = vector2(Int32(columns), Int32(rows))
        
        return GKNoiseMap(noise, size: size, origin: origin, sampleCount: sampleCount, seamless: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
}
