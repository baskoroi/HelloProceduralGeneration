//
//  GameStateHandler.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/13/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

protocol GameStateDelegate: class {
    func setupGameState()
    func lose()
    func win()
    func updateTimerDisplay()
}

class GameStateHandler {
    var secondsElapsed: TimeInterval = 0 {
        didSet {
            self.delegate?.updateTimerDisplay()
        }
    }
    var isWon = false
    var timerLabel: SKLabelNode?
    
    weak var delegate: GameStateDelegate?
    
    func setup() {
        self.delegate?.setupGameState()
    }
}
