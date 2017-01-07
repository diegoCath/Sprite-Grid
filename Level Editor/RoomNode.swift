//
//  RoomLayer.swift
//  Level Editor
//
//  Created by Diego Cathalifaud on 2/8/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

import SpriteKit

class RoomNode: SKNode {
    
    var grid = [[[GridElement?]]]()      // depth -> y -> x
    var allElements = [GridElement]()
    
    var gridNode = SKNode()
    
    let lock = NSLock()
    
    static var tileSize: Double!
    
    override init() {
        super.init()
        
        self.setupGridNode()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupGridNode() {
        
        self.gridNode.zPosition = 100
        
        let xMax = RoomNode.tileSize * Double(K.Parameters.kNumTilesX)
        let yMax = RoomNode.tileSize * Double(K.Parameters.kNumTilesY)
        
        for i in 0...K.Parameters.kNumTilesY {
            let hLine = SKShapeNode()
            let hPath = CGMutablePath()
            hPath.move(to: CGPoint(x: 0.0, y: Double(i) *  RoomNode.tileSize))
            hPath.addLine(to: CGPoint(x: xMax, y: Double(i) *  RoomNode.tileSize))
            hLine.path = hPath
            hLine.strokeColor = UIColor.white.withAlphaComponent(0.2)
            hLine.lineWidth = 1
            self.gridNode.addChild(hLine)
        }
        
        for i in 0...K.Parameters.kNumTilesX {
            let vLine = SKShapeNode()
            let vPath = CGMutablePath()
            vPath.move(to: CGPoint(x: Double(i) *  RoomNode.tileSize, y: 0.0))
            vPath.addLine(to: CGPoint(x: Double(i) *  RoomNode.tileSize, y: yMax))
            vLine.path = vPath
            vLine.strokeColor = UIColor.white.withAlphaComponent(0.2)
            vLine.lineWidth = 1
            self.gridNode.addChild(vLine)
        }
    }
    
    func clear() {
        
        // remove all elements and reset lists
        self.removeAllChildren()
        self.allElements = [GridElement]()
        
        let tiles = Array(repeating: [GridElement?](repeating: nil, count: K.Parameters.kNumTilesX), count: K.Parameters.kNumTilesY)
        let items = Array(repeating: [GridElement?](repeating: nil, count: K.Parameters.kNumTilesX), count: K.Parameters.kNumTilesY)
        let objects = Array(repeating: [GridElement?](repeating: nil, count: K.Parameters.kNumTilesX), count: K.Parameters.kNumTilesY)
        self.grid = [tiles, items, objects]
        self.addChild(self.gridNode)
    }
    
    func loadElements(_ elements: [GridElement]) {
        
        for element in elements {
            self.addElement(element, x: element.x, y: element.y)
        }
    }
    
    func loadEmpty() {
        
        for i in 0 ..< K.Parameters.kNumTilesY {
            
            var row = [GridElement?]()
            
            for j in 0 ..< K.Parameters.kNumTilesX {
                
                let tileIndex = 0
                
                let element = GridElement(elementIndex: tileIndex, layerDepth: 0)
                (element.x, element.y) = (j, i)
                if let sprite = element.sprite {
                    
                    sprite.setScale(CGFloat(RoomNode.tileSize/90.0))
                    sprite.position = CGPoint(x: (Double(j) + 0.5) * RoomNode.tileSize, y: (Double(i) + 0.5) * RoomNode.tileSize)
                    self.addChild(sprite)
                }
                
                row.append(element)
                self.allElements.append(element)
            }
            
            self.grid[0][i] = row
        }
    }
    
    func addElement(_ element: GridElement, x: Int, y: Int) {
        
        if let sprite = element.sprite {
            
            sprite.setScale(CGFloat(RoomNode.tileSize/90.0))
            sprite.position = CGPoint(x: (Double(x) + 0.5) * RoomNode.tileSize, y: (Double(y) + 0.5) * RoomNode.tileSize)
            self.addChild(sprite)
            
            let depth = element.layerDepth
            
            if let elementToDelete = self.grid[depth][Int(y)][Int(x)] {
                
                // remove sprite from scene
                if let spriteToDelete = elementToDelete.sprite {
                    spriteToDelete.removeFromParent()
                }
                
                // remove element from allElements
                for i in 0...self.allElements.count - 1 {
                    if self.allElements[i].isEqual(elementToDelete) {
                        self.allElements.remove(at: i)
                        break
                    }
                }
            }
            
            self.grid[depth][Int(y)][Int(x)] = element
            self.allElements.append(element)
        }
    }
    
    func deleteTopElementAt(x: Int, y: Int) {
        
        if let elementToDelete = self.topElementAt(x: x, y: y) {
            
            // remove sprite from scene
            if let spriteToDelete = elementToDelete.sprite {
                spriteToDelete.removeFromParent()
            }
            
            // remove element from allElements
            for i in 0...self.allElements.count - 1 {
                if self.allElements[i].isEqual(elementToDelete) {
                    self.allElements.remove(at: i)
                    break
                }
            }
            
            // remove element from grid
            self.grid[elementToDelete.layerDepth][Int(y)][Int(x)] = nil
        }
    }
    
    func deleteElementAt(x: Int, y: Int, depth: Int) {
        
        if let elementToDelete = self.grid[depth][y][x] {
            
            // remove sprite from scene
            if let spriteToDelete = elementToDelete.sprite {
                spriteToDelete.removeFromParent()
            }
            
            // remove element from allElements
            for i in 0...self.allElements.count - 1 {
                if self.allElements[i].isEqual(elementToDelete) {
                    self.allElements.remove(at: i)
                    break
                }
            }
            
            // remove element from grid
            self.grid[elementToDelete.layerDepth][Int(y)][Int(x)] = nil
        }
    }
    
    func topElementAt(x: Int, y: Int) -> GridElement? {
        
        var elementToDelete: GridElement?
        
        if let e = self.grid[2][Int(y)][Int(x)] {
            elementToDelete = e
        }
            
        else if let e = self.grid[1][Int(y)][Int(x)] {
            elementToDelete = e
        }
        
        return elementToDelete
    }
}
