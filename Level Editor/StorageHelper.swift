//
//  SaveHelper.swift
//  Level Editor
//
//  Created by Diego Cathalifaud on 2/5/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

import UIKit

class StorageHelper: NSObject {
    
    class func saveDictionary(_ dictionary: [String: NSCoding], tag: String) {
        
        self.saveObject(dictionary as NSCoding, tag: tag);
    }
    
    class func saveArray(_ array: [NSCoding], tag: String) {
        
        self.saveObject(array as NSCoding, tag: tag);
    }
    
    class func loadDictionaryForTag(_ tag: String) -> [String: AnyObject] {
        
        guard let level = self.loadObjectForTag(tag) as? [String: AnyObject] else { return [:] }
        return level
    }
    
    class func loadArrayForTag(_ tag: String) -> [AnyObject] {
        
        guard let level = self.loadObjectForTag(tag) as? [AnyObject] else { return [] }
        return level
    }
    
    class fileprivate func saveObject(_ object: NSCoding, tag: String) {
        
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        let filename = getDocumentsDirectory() + ("/\(tag).txt")
        try? data.write(to: URL(fileURLWithPath: filename), options: [.atomic])
    }
    
    class fileprivate func loadObjectForTag(_ tag: String) -> Any? {
        
        let filename = getDocumentsDirectory() + ("/\(tag).txt")
        let level = NSKeyedUnarchiver.unarchiveObject(withFile: filename)
        return level
    }
    
    fileprivate class func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
