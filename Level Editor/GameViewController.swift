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
    
    fileprivate let reuseIdentifier = "TileCell"
    
    var gameScene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.saveGame), name: NSNotification.Name(rawValue: K.Notifications.kNotifBackground), object: nil)
        
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        
        let coordinatesLabelMaxY: Int
        let actionButtonsMinY: Int
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            coordinatesLabelMaxY = 30
            actionButtonsMinY = Int(skView.bounds.size.height) - 300 - 42
        } else {
            coordinatesLabelMaxY = 30
            actionButtonsMinY = Int(skView.bounds.size.height) - 180 - 32
        }
        
        
        let width = Int(skView.bounds.size.width)
        let height = actionButtonsMinY - coordinatesLabelMaxY
        
        gameScene = GameScene(screenSize: skView.frame.size, usableFrame: CGRect(x: 0, y: coordinatesLabelMaxY, width: width, height: height))
        gameScene.scaleMode = .resizeFill
        gameScene.scrollDelegate = self
        
        if let elements = StorageHelper.loadArrayForTag("level 0_0") as? [GridElement] {
            gameScene.loadLevel(elements, direction: nil)
        }
        
        let directions = [(-1, 0, Direction.left), (1, 0, Direction.right), (0, 1, Direction.up), (0, -1, Direction.down)]
        
        for direction in directions {
            if let elements = StorageHelper.loadArrayForTag("level \(direction.0)_\(direction.1)") as? [GridElement] {
                gameScene.loadLevel(elements, direction: direction.2)
            }
        }
        
        self.defaultLabelMargin = self.bgLayerHorizontalConstraint.constant
        
        skView.presentScene(gameScene)
    }

    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func saveGame() {
        if(self.gameScene.shouldSave) {
            StorageHelper.saveArray(self.gameScene.allElements, tag: "level \(self.levelX)_\(self.levelY)")
        }
    }
    
    @IBAction func moveButtonTapped(_ sender: AnyObject) {
        
        self.deselectSelectedElement()
        sender.layer.borderWidth = 2.0
        sender.layer.borderColor = UIColor.orange.cgColor
        self.deleteButton.layer.borderColor = UIColor.clear.cgColor
        
        self.gameScene.userAction = .moving
    }
    
    @IBAction func deleteButtonTapped(_ sender: AnyObject) {
        
        self.deselectSelectedElement()
        sender.layer.borderWidth = 2.0
        sender.layer.borderColor = UIColor.orange.cgColor
        self.moveButton.layer.borderColor = UIColor.clear.cgColor
        
        self.gameScene.userAction = .deleting
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
            
            prevSelectedCollectionView?.reloadItems(at: [IndexPath(row: prevIndex, section: 0)])
        }
    }
}

extension GameViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        
            if let layerArray = AssetsHelper.sharedInstance.layerArrayForDepth(collectionView.tag) {
                return layerArray.count
            }
            
            return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
            
            if collectionView.tag == self.gameScene.selectedElementLayer && indexPath.row == self.gameScene.selectedElementIndex {
                cell.layer.borderWidth = cell.bounds.size.width/10.0
                cell.layer.borderColor = UIColor.orange.cgColor
            }
            else {
                cell.layer.borderColor = UIColor.clear.cgColor
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

    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            let tileSize = Int(self.view.frame.width)/K.Parameters.kNumTilesX
            return CGSize(width: tileSize, height: tileSize)
    }
    
    func collectionView(_ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
            if collectionView.tag != self.gameScene.selectedElementLayer || indexPath.row != self.gameScene.selectedElementIndex {
                
                self.moveButton.layer.borderColor = UIColor.clear.cgColor
                self.deleteButton.layer.borderColor = UIColor.clear.cgColor
                
                self.deselectSelectedElement()
                
                self.gameScene.userAction = .placing
                
                self.gameScene.selectedElementLayer = collectionView.tag
                self.gameScene.selectedElementIndex = indexPath.row
                
                collectionView.reloadItems(at: [indexPath])
            }
            
            return false
    }
}

extension GameViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var constraint = self.bgLayerHorizontalConstraint
        
        if scrollView.tag == 1 {
            constraint = self.layer1HorizontalConstraint
        }
        else if scrollView.tag == 2 {
            constraint = self.layer2HorizontalConstraint
        }
        
        if scrollView.frame.origin.x > 0 && scrollView.contentOffset.x > 0 {
            
            let delta = min(scrollView.contentOffset.x, scrollView.frame.origin.x)
            
            constraint?.constant -= delta
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        var constraint = self.bgLayerHorizontalConstraint
        
        if scrollView.tag == 1 {
            constraint = self.layer1HorizontalConstraint
        }
        else if scrollView.tag == 2 {
            constraint = self.layer2HorizontalConstraint
        }
        
        if(scrollView.frame.origin.x > 0) {
            
            constraint?.constant = self.defaultLabelMargin
            UIView.animate(withDuration: 0.1, animations: {
                scrollView.setContentOffset(scrollView.contentOffset, animated: false)
                self.view.layoutIfNeeded()
            }) 
        }
    }
}

extension GameViewController: GameSceneScrollDelegate {
    
    func gameScene(_ gameScene: GameScene, willScrollWithDirection direction: Direction) {
        
        self.saveGame()
    }
    
    func gameScene(_ gameScene: GameScene, didScrollWithDirection direction: Direction) {
        
        switch direction {
        case .left:
            self.levelX -= 1
        case .right:
            self.levelX += 1
        case .up:
            self.levelY += 1
        case .down:
            self.levelY -= 1
        }
        
        self.coordinatesLabel.text = "(\(self.levelX), \(self.levelY))"
        
        let omittedDirections: [Direction: Direction] = [.left: .right, .right: .left, .up: .down, .down: .up]
        let omittedDirection = omittedDirections[direction]!
        let directions = [(-1, 0, Direction.left), (1, 0, Direction.right), (0, 1, Direction.up), (0, -1, Direction.down)]
        
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
        
            for direction in directions {
                if direction.2 != omittedDirection {
                    if let elements = StorageHelper.loadArrayForTag("level \(self.levelX + direction.0)_\(self.levelY + direction.1)") as? [GridElement] {
                        
                        DispatchQueue.main.async {
                            gameScene.loadLevel(elements, direction: direction.2)
                        }
                    }
                }
            }
        }
    }
}
