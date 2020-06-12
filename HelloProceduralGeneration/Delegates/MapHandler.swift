//
//  Map.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/12/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol MapDelegate: class {
    func setupAllComponents()
    func setupLandTiles(tileSet: SKTileSet)
    func generateAcidSeas(tileSet: SKTileSet, fallbackTileGroup: SKTileGroup)
    func distributeTilesAroundMap(radius: simd_double1,
                                  layer: SKTileMapNode,
                                  tileSet: SKTileSet,
                                  tileGroupName: String,
                                  tileToAssign: TileContent,
                                  tilesToSkip: [TileContent],
                                  enableCollision: Bool)
    func findTileWithin5x5Cluster(for tilesToCheck: [TileContent],
                                  column: Int,
                                  row: Int,
                                  maxColumnIndex: Int,
                                  maxRowIndex: Int) -> Bool
    func generatePerlinNoiseMap(columns: Int, rows: Int) -> GKNoiseMap
}

class MapHandler {
    
    weak var delegate: MapDelegate?
    
    let node = SKNode()
    var tiles = Array(
        repeating: Array(repeating: TileCategory.ground, count: 128),
        count: 128
    )
    
    let numTilesOnSide = 128
    let tileSize = CGSize(width: 128, height: 128)
    let (rows, columns) = (128, 128)
    let area = CGSize(width: 128 * 128, height: 128 * 128)
    
    func setup() {
        delegate?.setupAllComponents()
    }
    
}
