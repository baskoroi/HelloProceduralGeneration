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
    func updateEnergyDisplay()
    
    // battery usage and pause (for pause screen)
    func useBattery(for dischargeDuration: Int)
    func pauseUsingBattery()
}

class EnergyBarHandler {
    
    // 10: full -> 0: empty
    var batteryLevel: Int = 7 {
        didSet {
            // update battery level on HUD, as it drops or gets recharged
            self.delegate?.updateEnergyDisplay()
            
            if batteryLevel <= 4 {
                dischargeDuration = 50
            }
        }
    }
    var minimumLevel: Int = 0
    var maximumLevel: Int = 10
    var isDead: Bool {
        batteryLevel == minimumLevel
    }
    
    var sprite: SKSpriteNode?
    var dischargeDuration: Int = 45
    
    weak var delegate: EnergyBarDelegate?
    
    func setup() {
        self.delegate?.setupEnergyBar()
    }
}
