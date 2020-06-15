//
//  TileCategory.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/12/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import Foundation

typealias TileContent = UInt32

struct TileCategory {
    static let none: TileContent            = 1 << 0
    static let ground: TileContent          = 1 << 0
    static let energyCellTaken: TileContent = 1 << 0
    static let boulder: TileContent         = 1 << 1
    static let acid: TileContent            = 1 << 2
    static let planeDebris: TileContent     = 1 << 3
    static let brokenRobots: TileContent    = 1 << 4
    static let energyCell: TileContent      = 1 << 5
    static let player: TileContent          = 1 << 6
    static let rescuePoint: TileContent     = 1 << 7
}
