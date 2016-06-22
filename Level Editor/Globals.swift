//
//  Constants.swift
//  Level Editor
//
//  Created by Diego Cathalifaud on 2/6/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

import SpriteKit

struct K {
    struct CodingKeys {
        static let kGridElementIndex = "kGridElementIndexKey"
        static let kGridElementDepth = "kGridElementDepthKey"
        static let kGridElementX = "kGridElementXKey"
        static let kGridElementY = "kGridElementYKey"
    }
    
    struct Notifications {
        static let kNotifBackground = "kNotifBackground"
    }
    
    struct Parameters {
        static let kNumTiles = 7
        static let kMaxTapScroll = 10.0
    }
}

enum Direction {
    case Left
    case Right
    case Up
    case Down
}

enum DirectionGuide {
    case Vertical
    case Horizontal
}

extension SKNode {
    
    func distance(p1 p1: CGPoint, p2: CGPoint) -> Double {
        return Double(hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y)));
    }
    
    func addPoints(p1 p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: p1.x + p2.x, y: p1.y + p2.y)
    }
}

