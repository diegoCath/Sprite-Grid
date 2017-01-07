//
//  GridElement.swift
//  Level Editor
//
//  Created by Diego Cathalifaud on 2/2/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

import SpriteKit

class GridElement: NSObject, NSCoding {
    
    let elementIndex: Int
    let layerDepth: Int
    var sprite: SKSpriteNode?
    var tag: String?
    var (x, y) = (0, 0)
    
    init(elementIndex: Int, layerDepth: Int) {
        
        self.elementIndex = elementIndex
        self.layerDepth = layerDepth
        
        // fetch element properties
        var fileName: String?
        if let elementDict = AssetsHelper.sharedInstance.elementAt(index: elementIndex, layerDepth: layerDepth) {
            fileName = elementDict["fileName"]
            self.tag = elementDict["tag"]
        }
        
        // assign fileName and tag
        if let realizedFileName = fileName {
            self.sprite = SKSpriteNode(imageNamed: realizedFileName)
            self.sprite?.zPosition = CGFloat(self.layerDepth)
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let index = aDecoder.decodeCInt(forKey: K.CodingKeys.kGridElementIndex)
        let depth = aDecoder.decodeCInt(forKey: K.CodingKeys.kGridElementDepth)
        let x = aDecoder.decodeCInt(forKey: K.CodingKeys.kGridElementX)
        let y = aDecoder.decodeCInt(forKey: K.CodingKeys.kGridElementY)
        
        self.init(elementIndex: Int(index), layerDepth: Int(depth))
        (self.x, self.y) = (Int(x), Int(y))
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encodeCInt(Int32(self.elementIndex), forKey: K.CodingKeys.kGridElementIndex)
        aCoder.encodeCInt(Int32(self.layerDepth), forKey: K.CodingKeys.kGridElementDepth)
        aCoder.encodeCInt(Int32(self.x), forKey: K.CodingKeys.kGridElementX)
        aCoder.encodeCInt(Int32(self.y), forKey: K.CodingKeys.kGridElementY)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        
        if let e = object {
            return (self.elementIndex == (e as AnyObject).elementIndex &&
                    self.layerDepth == (e as AnyObject).layerDepth &&
                    self.x == (e as AnyObject).x &&
                    self.y == (e as AnyObject).y)
        }
        
        return false
    }
}
