//
//  EnergyHandler.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/13/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import Foundation

protocol EnergyBarDelegate: class {
    
}

class EnergyBarHandler {
    // 10: full -> 0: empty
    var batteryLevel: Int = 10
    
    weak var delegate: EnergyBarDelegate?
}
