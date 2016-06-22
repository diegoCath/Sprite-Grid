//
//  SaveHelper.swift
//  Level Editor
//
//  Created by Diego Cathalifaud on 2/5/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

import UIKit

class StorageHelper: NSObject {
    
    class func saveDictionary(dictionary: [String: NSCoding], tag: String) {
        
        self.saveObject(dictionary, tag: tag);
    }
    
    class func saveArray(array: [NSCoding], tag: String) {
        
        self.saveObject(array, tag: tag);
    }
    
    class func loadDictionaryForTag(tag: String) -> [String: AnyObject] {
        
        guard let level = self.loadObjectForTag(tag) as? [String: AnyObject] else { return [:] }
        return level
    }
    
    class func loadArrayForTag(tag: String) -> [AnyObject] {
        
        guard let level = self.loadObjectForTag(tag) as? [AnyObject] else { return [] }
        return level
    }
    
    class private func saveObject(object: NSCoding, tag: String) {
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(object)
        let filename = getDocumentsDirectory().stringByAppendingString(("/\(tag).txt"))
        data.writeToFile(filename, atomically: true)
    }
    
    class private func loadObjectForTag(tag: String) -> Any? {
        
        let filename = getDocumentsDirectory().stringByAppendingString(("/\(tag).txt"))
        let level = NSKeyedUnarchiver.unarchiveObjectWithFile(filename)
        return level
    }
    
    private class func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
