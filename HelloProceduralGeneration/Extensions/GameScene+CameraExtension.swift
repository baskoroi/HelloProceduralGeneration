//
//  GameScene+CameraExtension.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/12/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

extension GameScene: CameraDelegate {
    func setupCamera() {
        cameraHandler.node = SKCameraNode()
        self.camera = cameraHandler.node
        self.addChild(cameraHandler.node!)
        let zoomInAction = SKAction.scale(
            to: CGFloat(1) / cameraHandler.zoomInFactor, duration: 1)
        cameraHandler.node!.run(zoomInAction)
    }
}
