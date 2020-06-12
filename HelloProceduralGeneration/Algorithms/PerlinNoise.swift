//
//  PerlinNoise.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/12/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import GameplayKit

class PerlinNoise {
    static func generateNoiseMap(columns: Int, rows: Int) -> GKNoiseMap {
       let source = GKPerlinNoiseSource()
       source.persistence = 0.9
       
       let noise = GKNoise(source)
       let size = vector2(1.0, 1.0)
       let origin = vector2(0.0, 0.0)
       let sampleCount = vector2(Int32(columns), Int32(rows))
       
       return GKNoiseMap(noise, size: size, origin: origin,
                         sampleCount: sampleCount, seamless: true)
    }

}

