//
//  GameScene+PhysicsContactExtension.swift
//  HelloProceduralGeneration
//
//  Created by Baskoro Indrayana on 06/12/20.
//  Copyright © 2020 Baskoro Indrayana. All rights reserved.
//

import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask |
            contact.bodyB.categoryBitMask
        
        if contactMask == TileCategory.acid | TileCategory.player {
            energyBarHandler.delegate?.kill()
        }
    }
    
    // use line sweep algorithm (i.e. with bottom-left & top-right
    // corner coordinates) to create physics bodies on acid
    // credits & reference:
    // https://stackoverflow.com/questions/47645039/connect-physicsbodies-on-tilemap-in-spritekit
    func createPhysicsBodiesOnAcid() {
        let (bottomLeftCorners, topRightCorners) = determineTileCorners()
        
        drawAcidPhysicsBodies(bottomLeftCorners: bottomLeftCorners,
                              topRightCorners: topRightCorners)
    }
    
    private func determineTileCorners() -> (bottomLeftCorners: [CGPoint],
                                            topRightCorners: [CGPoint]) {
        
        let tileWidth = mapHandler.tileSize.width
        let tileHeight = mapHandler.tileSize.height
        let radiusWidth = 0.5 * tileWidth
        let radiusHeight = 0.5 * tileHeight
        
        // will be used to draw the physics body rectangles
        var bottomLeftCorners = [CGPoint]()
        var topRightCorners = [CGPoint]()
                                                
        var currentTileIndex: Int = 0
        var leftAdjacentColumnIndex = 0
        
        var downLeftCornerPoint = CGPoint(x: 0, y: 0)
        
        let acidTilePositions = mapHandler.acidTilePositions
        
        for tile in acidTilePositions {
            let previousIndex = currentTileIndex - 1
            let nextIndex = currentTileIndex + 1
            
            // if either current tile is the first one (bottommost + leftmost),
            // or the current tile is in different column
            if (previousIndex < 0) || (acidTilePositions[previousIndex].y != mapHandler.acidTilePositions[currentTileIndex].y - tileHeight) {
                
                downLeftCornerPoint = CGPoint(x: tile.x - radiusWidth,
                                              y: tile.y - radiusHeight)
            }
            
            // if there's no more acid tiles
            if (nextIndex >= acidTilePositions.count) {
            
                bottomLeftCorners.append(downLeftCornerPoint)
                
                topRightCorners.append(CGPoint(x: tile.x + radiusWidth,
                                               y: tile.y + radiusHeight))
            
            } else if acidTilePositions[nextIndex].y !=
                (acidTilePositions[currentTileIndex].y + tileHeight) {
                
                if let _ = topRightCorners.first(where: { corner in
                
                    if corner == CGPoint(x: tile.x - radiusWidth,
                                         y: tile.y + radiusHeight) {
                    
                        leftAdjacentColumnIndex = topRightCorners.firstIndex(of: corner) ?? leftAdjacentColumnIndex
                    }
                    
                    return corner == CGPoint(x: tile.x - radiusWidth,
                                             y: tile.y + radiusHeight)
                    
                }) {
                    
                    // rewrite / expand previous rect's top right corner to
                    // that of current column
                    if bottomLeftCorners[leftAdjacentColumnIndex].y == downLeftCornerPoint.y {
                        
                        topRightCorners[leftAdjacentColumnIndex] = CGPoint(
                            x: tile.x + radiusWidth,
                            y: tile.y + radiusHeight
                        )
                        
                    } else {
                        
                        bottomLeftCorners.append(downLeftCornerPoint)
                        
                        topRightCorners.append(CGPoint(x: tile.x + radiusWidth,
                                                       y: tile.y + radiusHeight))
                        
                    }
                } else {
                    
                    bottomLeftCorners.append(downLeftCornerPoint)
                    
                    topRightCorners.append(CGPoint(x: tile.x + radiusWidth,
                                                   y: tile.y + radiusHeight))
                }
            }
            
            currentTileIndex += 1
        }
                                                
        return (bottomLeftCorners, topRightCorners)
    }
    
    private func drawAcidPhysicsBodies(bottomLeftCorners: [CGPoint],
                                       topRightCorners: [CGPoint]) {
        
        var rectangleIndex: Int = 0
        
        for blCorner in bottomLeftCorners {
        
            // use difference between bottom left & top right corners to
            // determine rectangle size for physics body
            let size = CGSize(width: abs(blCorner.x - topRightCorners[rectangleIndex].x),
                              height: abs(blCorner.y - topRightCorners[rectangleIndex].y))
            
            // for contact with acid, a physics body will be generated here
            let contactNode = SKNode()
            contactNode.physicsBody = SKPhysicsBody(rectangleOf: size)
            contactNode.physicsBody?.isDynamic = false
            contactNode.physicsBody?.affectedByGravity = false
            contactNode.physicsBody?.restitution = 0
            contactNode.physicsBody?.categoryBitMask = TileCategory.acid
            
            // no collision, player may overlap acid node,
            // only the contact is tested
            contactNode.physicsBody?.collisionBitMask = 0
            contactNode.physicsBody?.contactTestBitMask = TileCategory.player
            
            // determine origin / anchor point for contact node
            contactNode.position.x = blCorner.x + size.width / 2
            contactNode.position.y = blCorner.y + size.height / 2
            
            addChild(contactNode)
            
            rectangleIndex += 1
        }
    }
    
    func assignPhysicsBodyToTile(col: Int, row: Int,
                                 halfWidth: CGFloat,
                                 halfHeight: CGFloat,
                                 layer: SKTileMapNode,
                                 categoryBitMask: TileContent,
                                 collisionBitMask: TileContent = 0,
                                 contactTestBitMask: TileContent =
                                                     TileCategory.player) {
        
        let x = CGFloat(col) * mapHandler.tileSize.width - halfWidth
        let y = CGFloat(row) * mapHandler.tileSize.height - halfHeight
        
        let rect = CGRect(x: 0, y: 0,
                          width: mapHandler.tileSize.width,
                          height: mapHandler.tileSize.height)
        
        let tileNode = SKShapeNode(rect: rect)
        layer.addChild(tileNode)
        
        // remove default white stroke surrounding the SKShapeNode
        tileNode.strokeColor = .clear
        
        tileNode.position = CGPoint(x: x, y: y)
        
        tileNode.physicsBody = SKPhysicsBody(
            rectangleOf: mapHandler.tileSize,
            center: CGPoint(
                x: mapHandler.tileSize.width / 2.0,
                y: mapHandler.tileSize.height / 2.0
            )
        )
        tileNode.physicsBody?.isDynamic = false
        tileNode.physicsBody?.allowsRotation = false
        tileNode.physicsBody?.restitution = 0.0
        tileNode.physicsBody?.categoryBitMask = categoryBitMask
        tileNode.physicsBody?.collisionBitMask = collisionBitMask
        tileNode.physicsBody?.contactTestBitMask = contactTestBitMask
    }
}
