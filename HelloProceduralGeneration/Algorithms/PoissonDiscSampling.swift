//
//  PoissonDiscSampling.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/11/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import Foundation
import Darwin
import SpriteKit

// credits to Sebastian Lague for the implementation in Unity / C#
// (and his tutorial: https://www.youtube.com/watch?v=7WcmyxyFO7o)
class PoissonDiscSampling {
    
    static func generatePoints(radius: simd_double1,
                               sampleRegionSize: simd_double2,
                               numSamplesBeforeRejection: Int = 30) -> [simd_double2] {
        
        let cellSize: simd_double1 = radius / 2.squareRoot()
        
        let columns = (sampleRegionSize.x / cellSize).ceil()
        let rows    = (sampleRegionSize.y / cellSize).ceil()
        
        // set value of all elements to 0 by default
        var grid = Array(repeating: Array(repeating: 0, count: rows), count: columns)
        
        var points      = [simd_double2]()
        var spawnPoints = [simd_double2]()
        
        spawnPoints.append((sampleRegionSize / 2) - 1)
        while !spawnPoints.isEmpty {
            let spawnIndex = Int.random(in: 0..<spawnPoints.count)
            let spawnCenter = spawnPoints[spawnIndex]
            var candidateAccepted = false
            
            for _ in 0..<numSamplesBeforeRejection {
                let angle = simd_double1.random(in: 0...1) * simd_double1.pi * 2
                let directionVector = simd_double2(x: sin(angle), y: cos(angle))
                let candidateVector = spawnCenter + directionVector * simd_double1.random(in: radius...2*radius)
                if isValidCandidate(candidateVector,
                                    sampleRegionSize: sampleRegionSize,
                                    cellSize: cellSize,
                                    radius: radius,
                                    points: points,
                                    grid: grid) {
                    
                    points.append(candidateVector)
                    spawnPoints.append(candidateVector)
                    grid[(candidateVector.x / cellSize).floor()][(candidateVector.y / cellSize).floor()] = points.count
                    candidateAccepted = true
                    break
                }
            }
            
            if !candidateAccepted {
                spawnPoints.remove(at: spawnIndex)
            }
        }
        
        return points
    }
    
    static func isValidCandidate(_ candidateVector: simd_double2,
                                 sampleRegionSize: simd_double2,
                                 cellSize: simd_double1,
                                 radius: simd_double1,
                                 points: [simd_double2],
                                 grid: [[Int]]) -> Bool {
        
        if  (candidateVector.x >= 0 && candidateVector.x < sampleRegionSize.x) &&
            (candidateVector.y >= 0 && candidateVector.y < sampleRegionSize.y) {
        
            let cellX = Int(candidateVector.x / cellSize)
            let cellY = Int(candidateVector.y / cellSize)
            
            let searchStartX = max(0, cellX - 2)
            let searchEndX   = min(cellX + 2, grid.count - 1)
            let searchStartY = max(0, cellY - 2)
            let searchEndY   = min(cellY + 2, grid[0].count - 1)
            
            for x in searchStartX...searchEndX {
                for y in searchStartY...searchEndY {
                    let pointIndex = grid[x][y] - 1
                    if pointIndex != -1 {
                        let squareDistance = simd_length_squared(candidateVector - points[pointIndex])
                        if squareDistance < (radius * radius) {
                            return false
                        }
                    }
                }
            }
            return true
        }
        
        return false
    }
    
}

extension Double {
    func ceil() -> Int {
        return Int(self.rounded(.up))
    }
    
    func floor() -> Int {
        return Int(self.rounded(.down))
    }
}
