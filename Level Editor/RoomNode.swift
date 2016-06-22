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
    
    var tileSize = 45.0
    
    override init() {
        super.init()
        
        self.setupGridNode()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupGridNode() {
        
        self.gridNode.zPosition = 100;
        
        for i in 0...6 {
            
            let hLine = SKShapeNode();
            let hPath = CGPathCreateMutable();
            CGPathMoveToPoint(hPath, nil, 0.0, CGFloat(i) *  45.0);
            CGPathAddLineToPoint(hPath, nil, 315.0, CGFloat(i) *  45.0);
            hLine.path = hPath;
            hLine.strokeColor = UIColor.grayColor().colorWithAlphaComponent(0.5);
            self.gridNode.addChild(hLine)
            
            let vLine = SKShapeNode();
            let vPath = CGPathCreateMutable();
            CGPathMoveToPoint(vPath, nil, CGFloat(i) *  45.0, 0.0);
            CGPathAddLineToPoint(vPath, nil, CGFloat(i) *  45.0, 315.0);
            vLine.path = vPath;
            vLine.strokeColor = UIColor.grayColor().colorWithAlphaComponent(0.5);
            self.gridNode.addChild(vLine)
        }
    }
    
    func clear() {
        
        // remove all elements and reset lists
        self.removeAllChildren()
        self.allElements = [GridElement]()
        
        let tiles = Array(count:K.Parameters.kNumTiles, repeatedValue:[GridElement?](count:K.Parameters.kNumTiles, repeatedValue: nil))
        let items = Array(count:K.Parameters.kNumTiles, repeatedValue:[GridElement?](count:K.Parameters.kNumTiles, repeatedValue: nil))
        let objects = Array(count:K.Parameters.kNumTiles, repeatedValue:[GridElement?](count:K.Parameters.kNumTiles, repeatedValue: nil))
        self.grid = [tiles, items, objects]
        self.addChild(gridNode)
    }
    
    func loadElements(elements: [GridElement]) {
        
        for element in elements {
            self.addElement(element, x: element.x, y: element.y)
        }
    }
    
    func loadEmpty() {
        
        for var i = 0; i < K.Parameters.kNumTiles; i++ {
            
            var row = [GridElement?]()
            
            for var j = 0; j < K.Parameters.kNumTiles; j++ {
                
                let tileIndex = 0
                
                let element = GridElement(elementIndex: tileIndex, layerDepth: 0)
                (element.x, element.y) = (j, i)
                if let sprite = element.sprite {
                    
                    sprite.setScale(CGFloat(self.tileSize/90.0))
                    sprite.position = CGPoint(x: (Double(j) + 0.5) * self.tileSize, y: (Double(i) + 0.5) * self.tileSize)
                    self.addChild(sprite)
                }
                
                row.append(element)
                self.allElements.append(element)
            }
            
            self.grid[0][i] = row
        }
    }
    
    func addElement(element: GridElement, x: Int, y: Int) {
        
        if let sprite = element.sprite {
            
            sprite.setScale(CGFloat(self.tileSize/90.0))
            sprite.position = CGPoint(x: (Double(x) + 0.5) * self.tileSize, y: (Double(y) + 0.5) * self.tileSize)
            self.addChild(sprite)
            
            let depth = element.layerDepth
            
            if let elementToDelete = self.grid[depth][Int(y)][Int(x)] {
                
                // remove sprite from scene
                if let spriteToDelete = elementToDelete.sprite {
                    spriteToDelete.removeFromParent();
                }
                
                // remove element from allElements
                for i in 0...self.allElements.count - 1 {
                    if self.allElements[i].isEqual(elementToDelete) {
                        self.allElements.removeAtIndex(i)
                        break
                    }
                }
            }
            
            self.grid[depth][Int(y)][Int(x)] = element
            self.allElements.append(element)
        }
    }
    
    func deleteTopElementAt(x x: Int, y: Int) {
        
        if let elementToDelete = self.topElementAt(x: x, y: y) {
            
            // remove sprite from scene
            if let spriteToDelete = elementToDelete.sprite {
                spriteToDelete.removeFromParent();
            }
            
            // remove element from allElements
            for i in 0...self.allElements.count - 1 {
                if self.allElements[i].isEqual(elementToDelete) {
                    self.allElements.removeAtIndex(i)
                    break
                }
            }
            
            // remove element from grid
            self.grid[elementToDelete.layerDepth][Int(y)][Int(x)] = nil
        }
    }
    
    func deleteElementAt(x x: Int, y: Int, depth: Int) {
        
        if let elementToDelete = self.grid[depth][y][x] {
            
            // remove sprite from scene
            if let spriteToDelete = elementToDelete.sprite {
                spriteToDelete.removeFromParent();
            }
            
            // remove element from allElements
            for i in 0...self.allElements.count - 1 {
                if self.allElements[i].isEqual(elementToDelete) {
                    self.allElements.removeAtIndex(i)
                    break
                }
            }
            
            // remove element from grid
            self.grid[elementToDelete.layerDepth][Int(y)][Int(x)] = nil
        }
    }
    
    func topElementAt(x x: Int, y: Int) -> GridElement? {
        
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
