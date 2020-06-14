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
    func setupMap()
    func setupLandTiles(tileSet: SKTileSet)
    func generateAcidSeas(tileSet: SKTileSet, fallbackTileGroup: SKTileGroup)
    func distributeTilesAroundMap(radius: simd_double1,
                                  layer: SKTileMapNode,
                                  tileSet: SKTileSet,
                                  tileGroupName: String,
                                  tileToAssign: TileContent,
                                  tilesToSkip: [TileContent],
                                  enableCollision: Bool)
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
    
    var acidTilePositions = [CGPoint]()
    var itemsLayer: SKTileMapNode?
    var tileSet: SKTileSet?
    
    func setup() {
        delegate?.setupMap()
    }
    
}
