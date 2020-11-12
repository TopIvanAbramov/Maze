//
//  GameViewController.swift
//  Maze
//
//  Created by Иван Абрамов on 09.11.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

protocol LoadMapDelegate {
    func generated(map: String, withX x: Int, andY y: Int)
}

class GameViewController: UIViewController, SocketEventDelegate, RequestMapDelegate {
    
    func connected() {
         self.socketConnector.requestMap(withWidth: Constants.numberOfCellsHeight, andHeight: Constants.numberOfCellsWidth)
    }
    
    
    var loadLevelDelegate: LoadMapDelegate?
    
    func generateNewMap(height: Int, width: Int) {
        
        if socketConnector.socket.status == .connected {
            self.socketConnector.requestMap(withWidth: height, andHeight: width)
        } else {

        }
    }
    
    
    func generated(map: String, withX x: Int, andY y: Int) {
//        print("Map \(map) X: \(x) Y: \(y)")
        
        loadLevelDelegate?.generated(map: map, withX: x, andY: y)
    }
    

    let socketConnector = SocketConnector.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        socketConnector.delegate = self
        
        socketConnector.connect {
           
        }
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                self.loadLevelDelegate = scene
                scene.mapDelegate = self
                // Present the scene

                scene.size = view.bounds.size
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
