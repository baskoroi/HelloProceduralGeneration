//
//  GameStateHandler.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/13/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

enum GameState {
    case menu
    case playing
    case paused
    case won
    case lost
}

protocol GameStateDelegate: class {
    func setupGameState()
    
    // pause UI
    func pause()
    func resume()
    func restart()
    
    // end game states
    func lose()
    func win()
    
    // timer control
    func startTimer()
    func pauseTimer()
    
    func updateTimerDisplay()
}

class GameStateHandler {
    var secondsElapsed: TimeInterval = 0 {
        didSet {
            self.delegate?.updateTimerDisplay()
        }
    }
    var currentState: GameState = .playing
    var timerLabel: SKLabelNode?
    
    weak var delegate: GameStateDelegate?
    
    func setup() {
        self.delegate?.setupGameState()
    }
    
    var pauseScreen: SKSpriteNode?
}
