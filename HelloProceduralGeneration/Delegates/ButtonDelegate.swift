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

class SpriteButton: SKSpriteNode {
    weak var delegate: ButtonDelegate?
    
    init(imageName: String, buttonName: String) {
        let texture = SKTexture(imageNamed: imageName)
        let textureSize = CGSize(width: texture.size().width,
                                 height: texture.size().height)
        super.init(texture: texture, color: .clear, size: textureSize)
        self.name = buttonName
        self.isUserInteractionEnabled = true
    }
    
    init(uiImageSystemName: String,
         buttonName: String,
         tintColor: UIColor,
         size: CGSize) {
        
        if let image = UIImage(systemName: uiImageSystemName)?
                           .withTintColor(tintColor),
            let data = image.pngData(),
            let newImage = UIImage(data: data) {
            
            let texture = SKTexture(image: newImage)
            super.init(texture: texture, color: .clear, size: size)
            
        } else {
            
            super.init(texture: nil, color: .clear, size: size)
        }
        
        self.name = buttonName
        self.isUserInteractionEnabled = true
    }
    
    init(node: SKSpriteNode, buttonName: String) {
        let texture = node.texture ?? SKTexture(imageNamed: buttonName)
        let textureSize = CGSize(width: texture.size().width,
                                 height: texture.size().height)
        super.init(texture: texture, color: .clear, size: textureSize)
        self.name = buttonName
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.onButtonTap(name: self.name ?? "")
    }
}

class LabelButton: SKLabelNode {
    weak var delegate: ButtonDelegate?
    
    init(text: String,
         buttonName: String,
         fontSize: CGFloat,
         fontColor: UIColor = .white,
         fontName: String = "PoiretOne-Regular") {
        
        super.init()
        self.text = text
        self.name = buttonName
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.fontName = fontName
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.onButtonTap(name: self.name ?? "")
    }
}
