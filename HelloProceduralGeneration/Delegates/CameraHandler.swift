//
//  CameraHandler.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/12/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

protocol CameraDelegate: class {
    func setupCamera()
}

class CameraHandler {
    var node: SKCameraNode?
    var zoomInFactor: CGFloat
    
    weak var delegate: CameraDelegate?
    
    init(zoomInFactor: CGFloat) {
        self.zoomInFactor = zoomInFactor
    }
    
    func setup() {
        self.delegate?.setupCamera()
    }
}
