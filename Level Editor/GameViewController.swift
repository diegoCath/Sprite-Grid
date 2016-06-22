//
//  GameViewController.swift
//  Level Editor
//
//  Created by Diego Cathalifaud on 12/13/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

/* @TODO: 

    - add initial menu with with settings:
        1) New Level -> Level Settings:
            * grid dungeon game: (n x m) screens, each screen with a (p x q) grid
            * platformer game: (p x q) scrollable grid
        2) Load
    
    - implement undo/redo
*/

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var bgLayerCollectionView: UICollectionView!
    @IBOutlet weak var layer1CollectionView: UICollectionView!
    @IBOutlet weak var layer2CollectionView: UICollectionView!
    
    @IBOutlet weak var bgLayerHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var layer1HorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var layer2HorizontalConstraint: NSLayoutConstraint!
    var defaultLabelMargin: CGFloat = 0.0
    
    @IBOutlet weak var moveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var coordinatesLabel: UILabel!
    
    var levelX = 0, levelY = 0
    
    private let reuseIdentifier = "TileCell"
    
    var gameScene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveGame", name: K.Notifications.kNotifBackground, object: nil)
        
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        gameScene = GameScene(size: skView.bounds.size)
        gameScene.scaleMode = .AspectFill
        gameScene.scrollDelegate = self
        
        if let elements = StorageHelper.loadArrayForTag("level 0_0") as? [GridElement] {
            gameScene.loadLevel(elements, direction: nil)
        }
        
        let directions = [(-1, 0, Direction.Left), (1, 0, Direction.Right), (0, 1, Direction.Up), (0, -1, Direction.Down)]
        
        for direction in directions {
            if let elements = StorageHelper.loadArrayForTag("level \(direction.0)_\(direction.1)") as? [GridElement] {
                gameScene.loadLevel(elements, direction: direction.2)
            }
        }
        
        self.defaultLabelMargin = self.bgLayerHorizontalConstraint.constant
        
        skView.presentScene(gameScene)
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func saveGame() {
        if(self.gameScene.shouldSave) {
            StorageHelper.saveArray(self.gameScene.allElements, tag: "level \(self.levelX)_\(self.levelY)")
        }
    }
    
    @IBAction func moveButtonTapped(sender: AnyObject) {
        
        self.deselectSelectedElement()
        sender.layer.borderWidth = 2.0
        sender.layer.borderColor = UIColor.orangeColor().CGColor
        self.deleteButton.layer.borderColor = UIColor.clearColor().CGColor
        
        self.gameScene.userAction = .Moving
    }
    
    @IBAction func deleteButtonTapped(sender: AnyObject) {
        
        self.deselectSelectedElement()
        sender.layer.borderWidth = 2.0
        sender.layer.borderColor = UIColor.orangeColor().CGColor
        self.moveButton.layer.borderColor = UIColor.clearColor().CGColor
        
        self.gameScene.userAction = .Deleting
    }
    
    func deselectSelectedElement() {
        
        if(self.gameScene.selectedElementIndex != nil && self.gameScene.selectedElementLayer != nil) {
            
            let prevLayer = self.gameScene.selectedElementLayer!
            let prevIndex = self.gameScene.selectedElementIndex!
            
            var prevSelectedCollectionView = bgLayerCollectionView
            
            if prevLayer == 1 {
                prevSelectedCollectionView = layer1CollectionView
            }
            else if prevLayer == 2 {
                prevSelectedCollectionView = layer2CollectionView
            }
            
            self.gameScene.selectedElementIndex = nil
            self.gameScene.selectedElementLayer = nil
            
            prevSelectedCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: prevIndex, inSection: 0)])
        }
    }
}

extension GameViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        
            if let layerArray = AssetsHelper.sharedInstance.layerArrayForDepth(collectionView.tag) {
                return layerArray.count
            }
            
            return 0
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell
            
            if collectionView.tag == self.gameScene.selectedElementLayer && indexPath.row == self.gameScene.selectedElementIndex {
                cell.layer.borderWidth = cell.bounds.size.width/10.0
                cell.layer.borderColor = UIColor.orangeColor().CGColor
            }
            else {
                cell.layer.borderColor = UIColor.clearColor().CGColor
            }
            
            let elementDict = AssetsHelper.sharedInstance.elementAt(index:indexPath.row, layerDepth: collectionView.tag)
            
            if let realizedElementDict = elementDict {
                let fileName = realizedElementDict["fileName"]
                cell.icon.image = UIImage(named:fileName!)
            }
            
            return cell
    }
}

extension GameViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
            var tileSize = 90
            
            if self.view.frame.width <= 320.0 {     // iphone
                tileSize = 45
            }
            
            return CGSize(width: tileSize, height: tileSize)
    }
    
    func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
            if collectionView.tag != self.gameScene.selectedElementLayer || indexPath.row != self.gameScene.selectedElementIndex {
                
                self.moveButton.layer.borderColor = UIColor.clearColor().CGColor
                self.deleteButton.layer.borderColor = UIColor.clearColor().CGColor
                
                self.deselectSelectedElement()
                
                self.gameScene.userAction = .Placing
                
                self.gameScene.selectedElementLayer = collectionView.tag
                self.gameScene.selectedElementIndex = indexPath.row
                
                collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            return false
    }
}

extension GameViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var constraint = self.bgLayerHorizontalConstraint
        
        if scrollView.tag == 1 {
            constraint = self.layer1HorizontalConstraint
        }
        else if scrollView.tag == 2 {
            constraint = self.layer2HorizontalConstraint
        }
        
        if scrollView.frame.origin.x > 0 && scrollView.contentOffset.x > 0 {
            
            let delta = min(scrollView.contentOffset.x, scrollView.frame.origin.x)
            
            constraint.constant -= delta
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        var constraint = self.bgLayerHorizontalConstraint
        
        if scrollView.tag == 1 {
            constraint = self.layer1HorizontalConstraint
        }
        else if scrollView.tag == 2 {
            constraint = self.layer2HorizontalConstraint
        }
        
        if(scrollView.frame.origin.x > 0) {
            
            constraint.constant = self.defaultLabelMargin
            UIView.animateWithDuration(0.1) {
                scrollView.setContentOffset(scrollView.contentOffset, animated: false)
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension GameViewController: GameSceneScrollDelegate {
    
    func gameScene(gameScene: GameScene, willScrollWithDirection direction: Direction) {
        
        self.saveGame()
    }
    
    func gameScene(gameScene: GameScene, didScrollWithDirection direction: Direction) {
        
        switch direction {
        case .Left:
            self.levelX -= 1
        case .Right:
            self.levelX += 1
        case .Up:
            self.levelY += 1
        case .Down:
            self.levelY -= 1
        }
        
        self.coordinatesLabel.text = "(\(self.levelX), \(self.levelY))"
        
        let omittedDirections: [Direction: Direction] = [.Left: .Right, .Right: .Left, .Up: .Down, .Down: .Up]
        let omittedDirection = omittedDirections[direction]!
        let directions = [(-1, 0, Direction.Left), (1, 0, Direction.Right), (0, 1, Direction.Up), (0, -1, Direction.Down)]
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
        
            for direction in directions {
                if direction.2 != omittedDirection {
                    if let elements = StorageHelper.loadArrayForTag("level \(self.levelX + direction.0)_\(self.levelY + direction.1)") as? [GridElement] {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            gameScene.loadLevel(elements, direction: direction.2)
                        }
                    }
                }
            }
        }
    }
}
