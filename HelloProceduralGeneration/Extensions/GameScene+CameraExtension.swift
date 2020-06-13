//
//  GameScene+CameraExtension.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/12/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

struct ScreenHelper {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
    static let scale = UIScreen.main.scale
}

extension GameScene: CameraDelegate {
    func setupCamera() {
        cameraHandler.node = SKCameraNode()
        guard let cameraNode = cameraHandler.node else { return }
        self.addChild(cameraNode)
        self.camera = cameraNode

        setupHUD()
    }
    
    func setupHUD() {
        guard let cameraNode = cameraHandler.node else { return }
        
        let (width, height, scale) = (ScreenHelper.width,
                                      ScreenHelper.height,
                                      ScreenHelper.scale)
        
        print(width, height)
        let energyBar = SKSpriteNode(imageNamed: "energy10")
        cameraNode.addChild(energyBar)
        energyBar.zPosition = 5
        energyBar.setScale(1.75)
        energyBar.position = CGPoint(x: -width / 2 + 112, y: height / 2 + 72)
    }
}
