//
//  RandomQueue.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/11/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import Foundation

class RandomQueue<T> {
    private var queue = [T]()
    
    init() {
        
    }
    
    func push(_ item: T) {
        queue.append(item)
    }
    
    func pop() -> T? {
        guard !queue.isEmpty else { return nil }
        
        let size = queue.count
        let index = Int.random(in: 0..<size)
        return queue.remove(at: index)
    }
    
    func clear() {
        guard !queue.isEmpty else { return }
        
        queue.removeAll()
    }
}
