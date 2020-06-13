//
//  EnergyHandler.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/13/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

protocol EnergyBarDelegate: class {
    func setupEnergyBar()
    func recharge(by levels: Int)
    func discharge(by levels: Int)
    func kill()
    func updateOnHUD()
}

class EnergyBarHandler {
    
    // 10: full -> 0: empty
    var batteryLevel: Int = 10 {
        didSet {
            // update battery level on HUD, as it drops or gets recharged
            self.delegate?.updateOnHUD()
            
            if batteryLevel < 4 {
                dischargeDuration = 20
            } else if batteryLevel < 8 {
                dischargeDuration = 25
            }
        }
    }
    var minimumLevel: Int = 0
    var maximumLevel: Int = 10
    var isDead: Bool {
        batteryLevel == minimumLevel
    }
    
    var sprite: SKSpriteNode?
    var dischargeDuration: Int = 30
    
    weak var delegate: EnergyBarDelegate?
    
    func setup() {
        self.delegate?.setupEnergyBar()
    }
}
