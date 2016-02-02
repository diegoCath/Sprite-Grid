//
//  GameViewController.swift
//  Level Editor
//
//  Created by Diego Cathalifaud on 12/13/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

// @TODO: use 3 collection views for items menu

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
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
    
    @IBAction func itemButtonClicked(sender: AnyObject) {
        let button = sender as! UIButton
        
        NSLog("tag: \(button.tag)")
    }
    
    func fileNameForItemTag(tag: Int) -> String? {
        switch tag {
        
        case 101:
            return "TileSnow"
        case 102:
            return "TileTempleBlue"
        case 103:
            return "TileTempleRed"
        case 102:
            return "TileTempleGreen"
        
        case 201:
            return "TileSnow"
        case 202:
            return "TileSnow"
        
        case 301:
            return "TileSnow"
        case 302:
            return "TileSnow"
        
        default:
            return nil
        }
    }
}
