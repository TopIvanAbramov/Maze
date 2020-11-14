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
    func generated(map: String)
}

class GameViewController: UIViewController {
    
    
    var loadLevelDelegate: LoadMapDelegate?
    private var userDefaults = UserDefaults.standard
    
    func setComplexityLevel() {
        UserDefaults.standard.set("h", forKey: "complexity")
    }
    
    func generateNewMap(height: Int, width: Int) {
        
        if socketConnector.socket.status == .connected {
            let complexityLevel: String = userDefaults.string(forKey: Constants.complexityLevel) ?? "medium"
            let vortexProb: Double = Constants.complexity[complexityLevel] ?? 0
            
            self.socketConnector.requestMap(withWidth: height, andHeight: width, vortexProb: vortexProb)
        } else {

        }
    }
    
    
    func generated(map: String) {
//        print("Map \(map) X: \(x) Y: \(y)")
        
        loadLevelDelegate?.generated(map: map)
    }
    

    let socketConnector = SocketConnector.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        socketConnector.delegate = self
        
        socketConnector.connect {
           
        }
        
//        GameScene
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MainMenu") as? MainMenu {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                scene.mainMenuDelegate = self
//                self.loadLevelDelegate = scene
//                scene.mapDelegate = self
                // Present the scene

                scene.size = view.bounds.size
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func loadGameScene() {
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
    
    func loadSettingsScene() {
        if let view = self.view as! SKView? {
                    // Load the SKScene from 'SettingsScene.sks'
                    if let scene = SKScene(fileNamed: "SettingsScene") as? SettingsScene {
                        // Set the scale mode to scale to fit the window
                        scene.scaleMode = .aspectFill
                        
                        scene.settingsDelegate = self
                        
                        // Present the scene

                        scene.size = view.bounds.size
                        view.presentScene(scene)
                    }
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
    }
    
    func loadMainMenu() {
        if let view = self.view as! SKView? {
                    // Load the SKScene from 'MainMenu.sks'
                    if let scene = SKScene(fileNamed: "MainMenu") as? MainMenu {
                        // Set the scale mode to scale to fit the window
                        scene.scaleMode = .aspectFill
                        
                        scene.mainMenuDelegate = self
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

extension GameViewController: SettingsSceneDelegate, GameDelegate, MainMenuDelegate {
    
    func downloadSettingsScene() {
        loadSettingsScene()
    }
    
    
    func downloadMainMenu() {
        loadMainMenu()
        
        print("Main menu")
    }
    
    
    func donwloadGameScene() {
        loadGameScene()
    }
}

extension GameViewController: SocketEventDelegate {
    
    func connected() {
        self.socketConnector.requestMap(withWidth: Constants.numberOfCellsHeight, andHeight: Constants.numberOfCellsWidth, vortexProb: 0.2)
    }
}
