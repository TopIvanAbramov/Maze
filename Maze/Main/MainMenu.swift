//
//  MainMenu.swift
//  Maze
//
//  Created by Иван Абрамов on 13.11.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

protocol MainMenuDelegate {
    func donwloadGameScene()
    func downloadSettingsScene()
}

class MainMenu: SKScene {
    
    var mainMenuDelegate: MainMenuDelegate?
    private var pauseButton: SKNode!
    private var mainButton: SKLabelNode!
    
    override func didMove(to view: SKView) {
        loadBackground(forView: view)
        createSettingsButton()
        createPlayButton()
        
        physicsWorld.contactDelegate = self
    }
    
    func loadBackground(forView view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: view.center.x, y: view.center.y)
        background.blendMode = .replace
        background.zPosition = -1
        background.size = CGSize (width: frame.maxX, height: frame.maxY)
        
        addChild(background)
    }
    
    func createSettingsButton() {
        pauseButton = SKSpriteNode(imageNamed: "settings")
        pauseButton?.position = CGPoint(x: 40, y: frame.maxY - 50)
        pauseButton?.zPosition = 2
        pauseButton.name = "settings"
        addChild(pauseButton)
    }
    
    func createPlayButton() {
        self.mainButton = SKLabelNode(fontNamed: "Apple SD Gothic Neo Bold")
        self.mainButton.position = CGPoint(x: self.frame.maxX / 2,
                                           y: self.frame.maxY / 4)
        
        self.mainButton.name = "mainButton"
        self.mainButton.zPosition = 3
        
        self.mainButton.text = "Play game"
        let background = SKShapeNode(rect: CGRect(x: -mainButton.frame.size.width / 2 - 15,
                                                  y: -12,
                                                  width: 175,
                                                  height: 50),
                                                  cornerRadius: 10)
        
        
        background.fillColor = #colorLiteral(red: 0.9803921569, green: 0.737254902, blue: 0.2392156863, alpha: 1)
        self.mainButton.addChild(background)

        background.zPosition = 0
        background.name = "play"
        background.isUserInteractionEnabled = false
        
        self.addChild(mainButton)
    }
}

extension MainMenu: SKPhysicsContactDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        
        let frontTouchedNode = atPoint(location).name
        
        if frontTouchedNode == "play" {
            mainMenuDelegate?.donwloadGameScene()
        } else if frontTouchedNode == "settings" {
            mainMenuDelegate?.downloadSettingsScene()
        }
    }
}
