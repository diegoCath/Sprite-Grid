//
//  GameScene.swift
//  Level Editor
//
//  Created by Diego Cathalifaud on 12/13/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

import SpriteKit

protocol GameSceneScrollDelegate {
    func gameScene(gameScene: GameScene, willScrollWithDirection direction: Direction);
    func gameScene(gameScene: GameScene, didScrollWithDirection direction: Direction);
}

class GameScene: SKScene {
    
    enum UserActionStatus {
        case Placing
        case Moving
        case Deleting
    }
    
    var scrollDelegate: GameSceneScrollDelegate?
    
    var userAction = UserActionStatus.Placing
    var selectedElementLayer: Int? = 0
    var selectedElementIndex: Int? = 0
    
    var cropNode = SKCropNode()
    var containerNode = SKNode()
    var currentRoomNode = RoomNode()
    var contiguousRoomNodes = [Direction: RoomNode]()
    
    var shouldSave = false
    
    var allElements: [GridElement] {
        return self.currentRoomNode.allElements
    }
    
    var grabbedElement: GridElement?
    
    var scrollDirection: DirectionGuide?
    var scrollAnchorPoint: CGPoint?
    
    var tileSize:Double = 90.0
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        var x_0 = 69.0;
        var y_0 = 350.0;
        
        // @TODO: improve iphone detection method
        if self.frame.width <= 320.0 {      // iphone
            self.tileSize = 45.0
            x_0 = 2.5
            y_0 = 216.5
        }
        
        let dim = self.tileSize * Double(K.Parameters.kNumTiles)
        let mask = SKSpriteNode(imageNamed: "Mask")
        mask.size = CGSize(width: dim, height: dim)
        mask.anchorPoint = CGPointZero
        self.cropNode.maskNode = mask
        self.cropNode.position = CGPoint(x: x_0, y: y_0)
        
        self.cropNode.addChild(self.containerNode)
        self.addChild(self.cropNode)
        
        self.containerNode.addChild(self.currentRoomNode)
        
        self.contiguousRoomNodes[.Left] = RoomNode()
        self.contiguousRoomNodes[.Right] = RoomNode()
        self.contiguousRoomNodes[.Up] = RoomNode()
        self.contiguousRoomNodes[.Down] = RoomNode()
        
        self.containerNode.addChild(contiguousRoomNodes[.Left]!)
        self.containerNode.addChild(contiguousRoomNodes[.Right]!)
        self.containerNode.addChild(contiguousRoomNodes[.Up]!)
        self.containerNode.addChild(contiguousRoomNodes[.Down]!)
        
        self.updateRoomsPositions()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        print("scene size: [\(self.frame.width), \(self.frame.height)]")
        print("scene position: [\(self.frame.origin.x), \(self.frame.origin.y)]")
    }
    
    func loadLevel(elements: [GridElement], direction: Direction?) {
        
        var node = self.currentRoomNode
        
        if let d = direction {
            node = self.contiguousRoomNodes[d]!
        }
        
        node.lock.lock()
        
        node.clear()
        if elements.count == 0 {
           node.loadEmpty()
        }
        else {
            node.loadElements(elements)
        }
        
        node.lock.unlock()
    }
    
    func scrollRoomsForDirection(direction: Direction) {
        
        self.scrollDelegate?.gameScene(self, willScrollWithDirection: direction)
        
        var inverseDirection = Direction.Right
        
        if direction == .Left {
            inverseDirection = .Right
        }
        else if direction == .Right {
            inverseDirection = .Left
        }
        else if direction == .Up {
            inverseDirection = .Down
        }
        else if direction == .Down {
            inverseDirection = .Up
        }
        
        let tempCurrentRoomNode = self.currentRoomNode
        let tempInverseRoomNode = self.contiguousRoomNodes[inverseDirection]!
        self.currentRoomNode = self.contiguousRoomNodes[direction]!
        self.contiguousRoomNodes[inverseDirection] = tempCurrentRoomNode
        self.contiguousRoomNodes[direction] = tempInverseRoomNode
        
        self.scrollDelegate?.gameScene(self, didScrollWithDirection: direction)
        
        self.shouldSave = false
    }
    
    func updateRoomsPositions() {
        
        let directions: [Direction] = [.Left, .Right, .Up, .Down]
        
        for d in directions {
            let node = self.contiguousRoomNodes[d]!
            let delta = Double(K.Parameters.kNumTiles) * self.tileSize
            let deltaDict = [
                Direction.Left: CGPoint(x: -delta, y: 0),
                Direction.Right: CGPoint(x: delta, y: 0),
                Direction.Up: CGPoint(x: 0, y: delta),
                Direction.Down: CGPoint(x: 0, y: -delta)]
            node.position = addPoints(p1: self.currentRoomNode.position, p2: deltaDict[d]!)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let locationInContainer = touch.locationInNode(self.containerNode)
            let locationInCurrentNode = touch.locationInNode(self.cropNode)
            
            let x = Int(floor(locationInCurrentNode.x / CGFloat(tileSize)))
            let y = Int(floor(locationInCurrentNode.y / CGFloat(tileSize)))
            
            if x >= 0 && x < K.Parameters.kNumTiles && y >= 0 && y < K.Parameters.kNumTiles {
                
                if self.userAction == .Moving {
                    
                    self.grabbedElement = self.currentRoomNode.topElementAt(x: x, y: y)
                    
                    if let realizedGrabbedElement = self.grabbedElement {
                        realizedGrabbedElement.sprite!.zPosition = 10
                    }
                }
            }
            
            if self.grabbedElement == nil {
                self.scrollAnchorPoint = locationInContainer
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let locationInCurrentNode = touch.locationInNode(self.cropNode)
            let locationInContainer = touch.locationInNode(self.containerNode)
            
            if self.userAction == .Moving {
                if let realizedGrabbedElement = self.grabbedElement {
                    
                    let x = min(max(0, Double(locationInCurrentNode.x)), Double(K.Parameters.kNumTiles) * tileSize - 1)
                    let y = min(max(0, Double(locationInCurrentNode.y + 40)), Double(K.Parameters.kNumTiles) * tileSize - 1)
                    
                    realizedGrabbedElement.sprite!.position = CGPoint(x: x, y: y)
                }
            }
                
            if self.grabbedElement == nil {
                
                self.containerNode.position = addPoints(p1: self.containerNode.position, p2: CGPoint(x: locationInContainer.x - self.scrollAnchorPoint!.x, y: locationInContainer.y - self.scrollAnchorPoint!.y))
                
                if self.scrollDirection == nil {
                    
                    let referencePoint = CGPoint(x: -self.currentRoomNode.position.x, y: -self.currentRoomNode.position.y)
                    
                    if distance(p1: referencePoint, p2: self.containerNode.position) > K.Parameters.kMaxTapScroll {
                        self.scrollDirection = .Horizontal
                        if abs(referencePoint.y - self.containerNode.position.y) >= abs(referencePoint.x - self.containerNode.position.x) {
                            self.scrollDirection = .Vertical
                        }
                    }
                }
                    
                else {
                    if self.scrollDirection == .Horizontal {
                        self.containerNode.position.y = -self.currentRoomNode.position.y
                    }
                    else if self.scrollDirection == .Vertical {
                        self.containerNode.position.x = -self.currentRoomNode.position.x
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
    
        for touch in touches {
            let locationInCurrentNode = touch.locationInNode(self.cropNode)
            
            let x = Int(floor(locationInCurrentNode.x / CGFloat(tileSize)))
            let y = Int(floor(locationInCurrentNode.y / CGFloat(tileSize)))
            
            if (self.userAction == .Placing || self.userAction == .Deleting) &&
                (x < 0 || x >= K.Parameters.kNumTiles || y < 0 || y >= K.Parameters.kNumTiles) {
            }
            else {
                switch self.userAction {
                    
                case .Placing:
                    if self.scrollDirection == nil && !self.containerNode.hasActions() && self.selectedElementLayer != nil && self.selectedElementIndex != nil {
                        let element = GridElement(elementIndex: self.selectedElementIndex!, layerDepth: self.selectedElementLayer!)
                        (element.x, element.y) = (x, y)
                        self.addElement(element, x: x, y: y)
                    }
                    
                case .Moving:
                    if let realizedGrabbedElement = self.grabbedElement {
                        self.currentRoomNode.grid[realizedGrabbedElement.layerDepth][realizedGrabbedElement.y][realizedGrabbedElement.x] = nil
                        let xFinal = Int(floor((Double(realizedGrabbedElement.sprite!.position.x)) / tileSize))
                        let yFinal = Int(floor((Double(realizedGrabbedElement.sprite!.position.y)) / tileSize))
                        
                        self.currentRoomNode.deleteElementAt(x: xFinal, y: yFinal, depth: realizedGrabbedElement.layerDepth)
                        
                        realizedGrabbedElement.x = xFinal
                        realizedGrabbedElement.y = yFinal
                        realizedGrabbedElement.sprite!.position = CGPoint(x: (Double(xFinal) + 0.5) * self.tileSize, y: (Double(yFinal) + 0.5) * self.tileSize)
                        self.currentRoomNode.grid[realizedGrabbedElement.layerDepth][yFinal][xFinal] = realizedGrabbedElement
                        realizedGrabbedElement.sprite!.zPosition = CGFloat(realizedGrabbedElement.layerDepth)
                        self.grabbedElement = nil
                    }
                    
                case .Deleting:
                    if self.scrollDirection == nil {
                        self.currentRoomNode.deleteTopElementAt(x: x, y: y)
                    }
                }
            }
        }
        
        let referencePoint = CGPoint(x: -self.currentRoomNode.position.x, y: -self.currentRoomNode.position.y)
        if distance(p1: referencePoint, p2: self.containerNode.position) > self.tileSize * Double(K.Parameters.kNumTiles) * 0.2 {
            
            var direction = Direction.Left
            if self.scrollDirection == .Horizontal {
                if self.containerNode.position.x <= referencePoint.x {
                    direction = .Right
                }
                else {
                    direction = .Left
                }
            }
            else if self.scrollDirection == .Vertical {
                if self.containerNode.position.y <= referencePoint.y {
                    direction = .Up
                }
                else {
                    direction = .Down
                }
            }
            
            self.scrollRoomsForDirection(direction)
            self.updateRoomsPositions()
        }
        
        self.containerNode.runAction(
            SKAction.moveTo(CGPoint(x: -self.currentRoomNode.position.x, y:-self.currentRoomNode.position.y), duration: 0.1))
        
        self.scrollDirection = nil
        self.grabbedElement = nil
    }
    
    func addElement(element: GridElement, x: Int, y: Int) {
        
        self.currentRoomNode.addElement(element, x: x, y: y)
        self.shouldSave = true
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
