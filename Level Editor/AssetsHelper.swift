//
//  PropertiesParcer.swift
//  Level Editor
//
//  Created by Diego Cathalifaud on 2/5/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

import UIKit

class AssetsHelper: NSObject {
    
    static let sharedInstance = AssetsHelper()
    
    var elementsPropertiesByLayer: NSArray?
    
    override init() {
        
        if let path = NSBundle.mainBundle().pathForResource("ElementsProperties", ofType: "plist") {
            elementsPropertiesByLayer = NSArray(contentsOfFile: path)
        }
    }
    
    func layerArrayForDepth(depth: Int) -> [[String : String]]? {
        if let array = self.elementsPropertiesByLayer {
            return array[depth] as? Array<[String : String]>
        }
        return nil
    }
    
    func elementAt(index index: Int, layerDepth: Int) -> [String : String]? {
        if let layerArray = self.layerArrayForDepth(layerDepth) {
            return layerArray[index]
        }
        return nil
    }
}
