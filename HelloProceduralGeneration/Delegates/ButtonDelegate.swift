//
//  ButtonDelegate.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/14/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

protocol ButtonDelegate: class {
    func onButtonTap(name buttonName: String)
}

class Button: SKSpriteNode {
    weak var delegate: ButtonDelegate?
    
    init(name: String) {
        let texture = SKTexture(imageNamed: name)
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = name
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.onButtonTap(name: self.name ?? "")
    }
}
