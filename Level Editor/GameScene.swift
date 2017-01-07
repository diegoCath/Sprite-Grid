//
//  GameScene.swift
//  Level Editor
//
//  Created by Diego Cathalifaud on 12/13/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

import SpriteKit

protocol GameSceneScrollDelegate {
    func gameScene(_ gameScene: GameScene, willScrollWithDirection direction: Direction);
    func gameScene(_ gameScene: GameScene, didScrollWithDirection direction: Direction);
}

class GameScene: SKScene {
    
    enum UserActionStatus {
        case placing
        case moving
        case deleting
    }
    
    var scrollDelegate: GameSceneScrollDelegate?
    
    var userAction = UserActionStatus.placing
    var selectedElementLayer: Int? = 0
    var selectedElementIndex: Int? = 0
    
    var cropNode = SKCropNode()
    var containerNode = SKNode()
    var currentRoomNode: RoomNode!
    var contiguousRoomNodes = [Direction: RoomNode]()
    
    var shouldSave = false
    
    var allElements: [GridElement] {
        return self.currentRoomNode.allElements
    }
    
    var grabbedElement: GridElement?
    
    var scrollDirection: DirectionGuide?
    var scrollAnchorPoint: CGPoint?
    
    let tileSize: Double
    
    init(screenSize:CGSize, usableFrame: CGRect) {
        
        self.tileSize = Double(min(usableFrame.width/CGFloat(K.Parameters.kNumTilesX), usableFrame.height/CGFloat(K.Parameters.kNumTilesY)))
        RoomNode.tileSize = self.tileSize
        self.currentRoomNode = RoomNode()
        
        super.init(size: screenSize)
        
        let x_0 = Double(usableFrame.width/2.0) - Double(K.Parameters.kNumTilesX) * tileSize/2.0
        let y_0 = Double(usableFrame.height/2.0) - Double(K.Parameters.kNumTilesY) * tileSize/2.0
        
        let dimX = self.tileSize * Double(K.Parameters.kNumTilesX)
        let dimY = self.tileSize * Double(K.Parameters.kNumTilesY)
        let mask = SKSpriteNode(imageNamed: "Mask")
        mask.size = CGSize(width: dimX, height: dimY)
        mask.anchorPoint = CGPoint.zero
        self.cropNode.maskNode = mask
        self.cropNode.position = CGPoint(x: x_0, y: y_0 + Double(screenSize.height - usableFrame.maxY))
        
        self.cropNode.addChild(self.containerNode)
        self.addChild(self.cropNode)
        
        self.containerNode.addChild(self.currentRoomNode)
        
        self.contiguousRoomNodes[.left] = RoomNode()
        self.contiguousRoomNodes[.right] = RoomNode()
        self.contiguousRoomNodes[.up] = RoomNode()
        self.contiguousRoomNodes[.down] = RoomNode()
        
        self.containerNode.addChild(contiguousRoomNodes[.left]!)
        self.containerNode.addChild(contiguousRoomNodes[.right]!)
        self.containerNode.addChild(contiguousRoomNodes[.up]!)
        self.containerNode.addChild(contiguousRoomNodes[.down]!)
        
        self.updateRoomsPositions()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        print("scene size: [\(self.frame.width), \(self.frame.height)]")
        print("scene position: [\(self.frame.origin.x), \(self.frame.origin.y)]")
    }
    
    func loadLevel(_ elements: [GridElement], direction: Direction?) {
        
        var node = self.currentRoomNode
        
        if let d = direction {
            node = self.contiguousRoomNodes[d]!
        }
        
        node?.lock.lock()
        
        node?.clear()
        if elements.count == 0 {
           node?.loadEmpty()
        }
        else {
            node?.loadElements(elements)
        }
        
        node?.lock.unlock()
    }
    
    func scrollRoomsForDirection(_ direction: Direction) {
        
        self.scrollDelegate?.gameScene(self, willScrollWithDirection: direction)
        
        var inverseDirection = Direction.right
        
        if direction == .left {
            inverseDirection = .right
        }
        else if direction == .right {
            inverseDirection = .left
        }
        else if direction == .up {
            inverseDirection = .down
        }
        else if direction == .down {
            inverseDirection = .up
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
        
        let directions: [Direction] = [.left, .right, .up, .down]
        let nTiles: [Direction: Int] = [.left:  K.Parameters.kNumTilesX,
                                        .right: K.Parameters.kNumTilesX,
                                        .up:    K.Parameters.kNumTilesY,
                                        .down:  K.Parameters.kNumTilesY]
        
        
        for d in directions {
            let node = self.contiguousRoomNodes[d]!
            let delta = Double(nTiles[d]!) * self.tileSize
            let deltaDict = [
                Direction.left: CGPoint(x: -delta, y: 0),
                Direction.right: CGPoint(x: delta, y: 0),
                Direction.up: CGPoint(x: 0, y: delta),
                Direction.down: CGPoint(x: 0, y: -delta)]
            node.position = addPoints(p1: self.currentRoomNode.position, p2: deltaDict[d]!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let locationInContainer = touch.location(in: self.containerNode)
            let locationInCurrentNode = touch.location(in: self.cropNode)
            
            let x = Int(floor(locationInCurrentNode.x / CGFloat(tileSize)))
            let y = Int(floor(locationInCurrentNode.y / CGFloat(tileSize)))
            
            if x >= 0 && x < K.Parameters.kNumTilesX && y >= 0 && y < K.Parameters.kNumTilesY {
                
                if self.userAction == .moving {
                    
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let locationInCurrentNode = touch.location(in: self.cropNode)
            let locationInContainer = touch.location(in: self.containerNode)
            
            if self.userAction == .moving {
                if let realizedGrabbedElement = self.grabbedElement {
                    
                    let x = min(max(0, Double(locationInCurrentNode.x)), Double(K.Parameters.kNumTilesX) * tileSize - 1)
                    let y = min(max(0, Double(locationInCurrentNode.y + 40)), Double(K.Parameters.kNumTilesY) * tileSize - 1)
                    
                    realizedGrabbedElement.sprite!.position = CGPoint(x: x, y: y)
                }
            }
                
            if self.grabbedElement == nil {
                
                self.containerNode.position = addPoints(p1: self.containerNode.position, p2: CGPoint(x: locationInContainer.x - self.scrollAnchorPoint!.x, y: locationInContainer.y - self.scrollAnchorPoint!.y))
                
                if self.scrollDirection == nil {
                    
                    let referencePoint = CGPoint(x: -self.currentRoomNode.position.x, y: -self.currentRoomNode.position.y)
                    
                    if distance(p1: referencePoint, p2: self.containerNode.position) > K.Parameters.kMaxTapScroll {
                        self.scrollDirection = .horizontal
                        if abs(referencePoint.y - self.containerNode.position.y) >= abs(referencePoint.x - self.containerNode.position.x) {
                            self.scrollDirection = .vertical
                        }
                    }
                }
                    
                else {
                    if self.scrollDirection == .horizontal {
                        self.containerNode.position.y = -self.currentRoomNode.position.y
                    }
                    else if self.scrollDirection == .vertical {
                        self.containerNode.position.x = -self.currentRoomNode.position.x
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
    
        for touch in touches {
            let locationInCurrentNode = touch.location(in: self.cropNode)
            
            let x = Int(floor(locationInCurrentNode.x / CGFloat(tileSize)))
            let y = Int(floor(locationInCurrentNode.y / CGFloat(tileSize)))
            
            if (self.userAction == .placing || self.userAction == .deleting) &&
                (x < 0 || x >= K.Parameters.kNumTilesX || y < 0 || y >= K.Parameters.kNumTilesY) {
            }
            else {
                switch self.userAction {
                    
                case .placing:
                    if self.scrollDirection == nil && !self.containerNode.hasActions() && self.selectedElementLayer != nil && self.selectedElementIndex != nil {
                        let element = GridElement(elementIndex: self.selectedElementIndex!, layerDepth: self.selectedElementLayer!)
                        (element.x, element.y) = (x, y)
                        self.addElement(element, x: x, y: y)
                    }
                    
                case .moving:
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
                    
                case .deleting:
                    if self.scrollDirection == nil {
                        self.currentRoomNode.deleteTopElementAt(x: x, y: y)
                    }
                }
            }
        }
        
        let referencePoint = CGPoint(x: -self.currentRoomNode.position.x, y: -self.currentRoomNode.position.y)
        if distance(p1: referencePoint, p2: self.containerNode.position) > self.tileSize * Double(K.Parameters.kNumTilesX) * 0.2 {
            
            var direction = Direction.left
            if self.scrollDirection == .horizontal {
                if self.containerNode.position.x <= referencePoint.x {
                    direction = .right
                }
                else {
                    direction = .left
                }
            }
            else if self.scrollDirection == .vertical {
                if self.containerNode.position.y <= referencePoint.y {
                    direction = .up
                }
                else {
                    direction = .down
                }
            }
            
            self.scrollRoomsForDirection(direction)
            self.updateRoomsPositions()
        }
        
        self.containerNode.run(
            SKAction.move(to: CGPoint(x: -self.currentRoomNode.position.x, y:-self.currentRoomNode.position.y), duration: 0.1))
        
        self.scrollDirection = nil
        self.grabbedElement = nil
    }
    
    func addElement(_ element: GridElement, x: Int, y: Int) {
        
        self.currentRoomNode.addElement(element, x: x, y: y)
        
        NSLog(self.currentRoomNode.calculateAccumulatedFrame().debugDescription)
        NSLog(self.view!.frame.debugDescription)
        
        self.shouldSave = true
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
