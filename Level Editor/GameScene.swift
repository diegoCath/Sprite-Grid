//
//  GameScene.swift
//  Level Editor
//
//  Created by Diego Cathalifaud on 12/13/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var tiles = [[SKNode]]()
    
    let tileSize:Double = 90.0
    let x_0 = 69.0;
    let y_0 = 380.0;
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        NSLog("scene size: [\(self.frame.width), \(self.frame.height)]")
        NSLog("scene position: [\(self.frame.origin.x), \(self.frame.origin.y)]")
        
        for var i = 0; i < 7; i++ {
            
            var row = [SKNode]()
            
            for var j = 0; j < 7; j++ {
                
                var imgName = "TileTempleGreen1"
                
                if i % 2 == j % 2 {
                    imgName = "TileTempleRed1"
                }
         
                let tile = SKSpriteNode(imageNamed: imgName)
                tile.position = CGPoint(x: x_0 + (Double(j) + 0.5) * self.tileSize, y: y_0 + (Double(i) + 0.5) * self.tileSize)
                self.addChild(tile)
                
                row.append(tile)
            }
            
            self.tiles.append(row)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let x = Int(floor((Double(location.x) - x_0) / tileSize))
            let y = Int(floor((Double(location.y) - y_0) / tileSize))
            
            if x < 0 || x >= 7 || y < 0 || y >= 7 {
                return;
            }
            
            print("\(x), \(y)")
            
            var tile = tiles[Int(y)][Int(x)]
            tile.removeFromParent();
            
            tile = SKSpriteNode(imageNamed: "TileSnow1")
            tile.position = CGPoint(x: x_0 + (Double(x) + 0.5) * self.tileSize, y: y_0 + (Double(y) + 0.5) * self.tileSize)
            self.addChild(tile)
            tiles[Int(y)][Int(x)] = tile
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
