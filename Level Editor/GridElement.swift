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
        
        let index = aDecoder.decodeIntForKey(K.CodingKeys.kGridElementIndex)
        let depth = aDecoder.decodeIntForKey(K.CodingKeys.kGridElementDepth)
        let x = aDecoder.decodeIntForKey(K.CodingKeys.kGridElementX)
        let y = aDecoder.decodeIntForKey(K.CodingKeys.kGridElementY)
        
        self.init(elementIndex: Int(index), layerDepth: Int(depth))
        (self.x, self.y) = (Int(x), Int(y))
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt(Int32(self.elementIndex), forKey: K.CodingKeys.kGridElementIndex)
        aCoder.encodeInt(Int32(self.layerDepth), forKey: K.CodingKeys.kGridElementDepth)
        aCoder.encodeInt(Int32(self.x), forKey: K.CodingKeys.kGridElementX)
        aCoder.encodeInt(Int32(self.y), forKey: K.CodingKeys.kGridElementY)
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        
        if let e = object {
            return (self.elementIndex == e.elementIndex &&
                    self.layerDepth == e.layerDepth &&
                    self.x == e.x &&
                    self.y == e.y)
        }
        
        return false
    }
}
