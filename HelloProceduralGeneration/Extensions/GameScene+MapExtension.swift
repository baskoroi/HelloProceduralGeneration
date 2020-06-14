//
//  GameScene+MapExtension.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/12/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

extension GameScene: MapDelegate {

    func setupMap() {
        // add the map and "zoom out"
        addChild(mapHandler.node)
        
        // retrieve tile sets from corresponding .sks files
        mapHandler.tileSet = SKTileSet(named: "Proxima Tile Set")
        guard let tileSet = mapHandler.tileSet else { return }
        
        // MARK: fill all tiles with land tiles, by default
        setupLandTiles(tileSet: tileSet)
        
        // MARK: generate acid seas using Perlin noise algorithm
        // boulders are allowed to overwrite acid seas
        let landTiles = tileSet.tileGroups.first { $0.name == "Land" }
        generateAcidSeas(tileSet: tileSet,
                         fallbackTileGroup: landTiles!)
        
        // create layer to insert items
        let itemsLayer = SKTileMapNode(tileSet: tileSet,
                                       columns: mapHandler.columns,
                                       rows: mapHandler.rows,
                                       tileSize: mapHandler.tileSize)
        itemsLayer.enableAutomapping = true
        mapHandler.node.addChild(itemsLayer)
        mapHandler.itemsLayer = itemsLayer
        
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
                                               TileCategory.boulder],
                                 enableCollision: false)
        
        // MARK: generate broken robots around land
        distributeTilesAroundMap(radius: 5,
                                 layer: itemsLayer,
                                 tileSet: tileSet,
                                 tileGroupName: "Broken Robot",
                                 tileToAssign: TileCategory.brokenRobots,
                                 tilesToSkip: [TileCategory.acid,
                                               TileCategory.boulder,
                                               TileCategory.energyCell],
                                 enableCollision: true)
        
        // MARK: generate plane debris around land
        distributeTilesAroundMap(radius: 6,
                                 layer: itemsLayer,
                                 tileSet: tileSet,
                                 tileGroupName: "Plane Debris",
                                 tileToAssign: TileCategory.brokenRobots,
                                 tilesToSkip: [TileCategory.acid,
                                               TileCategory.boulder,
                                               TileCategory.energyCell,
                                               TileCategory.brokenRobots],
                                 enableCollision: true)
        
        // TODO set up scene edge physics here
    }
    
    func setupLandTiles(tileSet: SKTileSet) {
        let landTiles = tileSet.tileGroups.first { $0.name == "Land" }
        let bottomLayer = SKTileMapNode(tileSet: tileSet,
                                        columns: mapHandler.columns,
                                        rows: mapHandler.rows,
                                        tileSize: mapHandler.tileSize)
        bottomLayer.fill(with: landTiles)
        mapHandler.node.addChild(bottomLayer)
    }
    
    func generateAcidSeas(tileSet: SKTileSet, fallbackTileGroup: SKTileGroup) {
        
        let (columns, rows) = (mapHandler.columns, mapHandler.rows)
        
        let acidTiles = tileSet.tileGroups.first { $0.name == "Acid" }
        let noiseMap = PerlinNoise.generateNoiseMap(columns: columns, rows: rows)
        let acidLayer = SKTileMapNode(tileSet: tileSet,
                                      columns: columns,
                                      rows: rows,
                                      tileSize: mapHandler.tileSize)
        acidLayer.enableAutomapping = true
        mapHandler.node.addChild(acidLayer)
        
        let halfWidth  = CGFloat(acidLayer.numberOfColumns) / 2.0 * mapHandler.tileSize.width
        let halfHeight = CGFloat(acidLayer.numberOfRows) / 2.0 * mapHandler.tileSize.height
        
        let tileSize = acidLayer.tileSize
        
        // set the tile, every column and every row
        for col in 0 ..< columns {
            for row in 0 ..< rows {
                
                // override boulder tiles - hence no validation
                
                let location = vector2(Int32(row), Int32(col))
                let terrainHeight = noiseMap.value(at: location)

                // increase terrainHeight to increase acid tile probability
                if terrainHeight < 0 {
                    
                    // set the tile to acid
                    acidLayer.setTileGroup(acidTiles!, forColumn: col, row: row)
                }
            }
        }
        
        // assign acid to mapHandler.tiles here, automapping adjacency rules
        // makes area grow beyond actual col & row
        for col in 0 ..< columns {
            for row in 0 ..< rows {
                if let tileDefinition = acidLayer.tileDefinition(atColumn: col, row: row) {
                    mapHandler.tiles[col][row] = TileCategory.acid
                    
                    let tile = SKSpriteNode()
                    
                    let x = round(CGFloat(col) * tileSize.width - halfWidth + (tileSize.width / 2))
                    let y = round(CGFloat(row) * tileSize.height - halfHeight + (tileSize.height / 2))

                    tile.position = CGPoint(x: x, y: y)
                    tile.size = CGSize(width: tileDefinition.size.width,
                                       height: tileDefinition.size.height)
                    
                    mapHandler.acidTilePositions.append(tile.position)
                }
            }
        }
        createPhysicsBodiesOnAcid()
    }
    
    // generate tiles with even positional distribution using
    // Poisson Disc Sampling algorithm
    func distributeTilesAroundMap(radius: simd_double1,
                                  layer: SKTileMapNode,
                                  tileSet: SKTileSet,
                                  tileGroupName: String,
                                  tileToAssign: TileContent,
                                  tilesToSkip: [TileContent],
                                  enableCollision: Bool) {
        
        let tiles = tileSet.tileGroups.first { $0.name == tileGroupName }
        
        let points = PoissonDiscSampling.generatePoints(radius: radius, sampleRegionSize: vector2(128,128))
        
        let halfWidth  = CGFloat(layer.numberOfColumns) / 2.0 * mapHandler.tileSize.width
        let halfHeight = CGFloat(layer.numberOfRows) / 2.0 * mapHandler.tileSize.height
        
        for point in points {
            let location = vector2(Int32(point.x), Int32(point.y))
            let (row, col) = (Int(location.y), Int(location.x))
            
            // some tiles cannot be placed above other tiles,
            // to avoid unintended overlaps
            // e.g. acid tiles cannot be placed close to surrounding boulder tiles
            if findTileWithin5x5Cluster(for: tilesToSkip,
                                        column: col,
                                        row: row,
                                        maxColumnIndex: mapHandler.numTilesOnSide - 1,
                                        maxRowIndex: mapHandler.numTilesOnSide - 1) {
                
                continue
            }
            
            layer.setTileGroup(tiles, forColumn: col, row: row)
            mapHandler.tiles[col][row] = tileToAssign
            
            if enableCollision {
                assignPhysicsBodyToTile(col: col, row: row, halfWidth: halfWidth, halfHeight: halfHeight, layer: layer, categoryBitMask: tileToAssign, collisionBitMask: TileCategory.player)
            } else {
                assignPhysicsBodyToTile(col: col, row: row, halfWidth: halfWidth, halfHeight: halfHeight, layer: layer, categoryBitMask: tileToAssign, collisionBitMask: 0, contactTestBitMask: TileCategory.player)
            }
        }
    }
    
    func findTileWithin5x5Cluster(for tilesToCheck: [TileContent],
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
                if tilesToCheck.contains(mapHandler.tiles[col][row]) {
                    return true
                }
            }
        }
        
        return false
    }
    
}
