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
    }
}
