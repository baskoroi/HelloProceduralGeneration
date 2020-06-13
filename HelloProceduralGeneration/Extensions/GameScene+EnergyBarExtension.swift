//
//  GameScene+EnergyBarExtension.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/13/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

extension GameScene: EnergyBarDelegate {
    
    func setupEnergyBar() {
        guard let cameraNode = cameraHandler.node else { return }
        
        let (width, height) = (ScreenHelper.width, ScreenHelper.height)
        
        let energyBarNode = SKSpriteNode(imageNamed: "energy10")
        energyBarHandler.sprite = energyBarNode
        guard let energySprite = energyBarHandler.sprite else {
            return
        }
        let dischargeDuration = energyBarHandler.dischargeDuration
        cameraNode.addChild(energySprite)
        energySprite.zPosition = 5
        energySprite.setScale(1.75)
        energySprite.position = CGPoint(x: -width / 2 + 112, y: height / 2 + 72)
        
        // battery discharges over time
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval(dischargeDuration)),
            SKAction.run { [weak self] in
                self?.discharge(by: 1)
            }
        ])))
    }
    
    func recharge(by levels: Int) {
        let previousLevel = energyBarHandler.batteryLevel
        energyBarHandler.batteryLevel = min(10, previousLevel + levels)
    }
    
    func discharge(by levels: Int) {
        let previousLevel = energyBarHandler.batteryLevel
        energyBarHandler.batteryLevel = max(0, previousLevel - levels)
    }
    
    func kill() {
        energyBarHandler.batteryLevel = 0
    }
    
    func updateEnergyDisplay() {
        guard let energySprite = energyBarHandler.sprite else { return }
        let level = energyBarHandler.batteryLevel
        energySprite.texture = SKTexture(imageNamed: "energy\(level)")
    }

}
