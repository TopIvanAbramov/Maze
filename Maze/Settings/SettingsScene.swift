//
//  SettingsScene.swift
//  Maze
//
//  Created by Иван Абрамов on 14.11.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import Foundation
import SpriteKit


protocol SettingsSceneDelegate {
    func downloadMainMenu()
}

class SettingsScene: SKScene {
    
    private var selectedColor: SKSpriteNode?
    private var selectedLevel: SKSpriteNode?
    private var exitButton: SKSpriteNode?
    private var ballColors: [SKSpriteNode] = []
    private var complexityLevels: [SKSpriteNode] = []
    var settingsDelegate: SettingsSceneDelegate?
    private var userDefaults = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        loadBackground(forView: view)
        createBackButton()
        loadBallColorsLabels()
        createSelectedColorButton()
        loadComplexityLevelLabels()
        createSelectedLevelButton()
    }
    
    func loadBackground(forView view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: view.center.x, y: view.center.y)
        background.blendMode = .replace
        background.zPosition = -1
        background.size = CGSize (width: frame.maxX, height: frame.maxY)
        
        addChild(background)
    }
    
    func createSelectedColorButton() {
        
        let ballColor: String = userDefaults.string(forKey: Constants.ballColor) ?? "playerBlue"
        
        ballColors.forEach { (node) in
            if node.name == ballColor {
                selectedColor = SKSpriteNode(imageNamed: "circle")
                selectedColor?.size = CGSize(width: 85, height: 85)
                selectedColor?.position = node.position
                selectedColor?.zPosition = 3
                selectedColor?.name = "selectedColor"
                addChild(selectedColor!)
                
                return
            }
        }
    }
    
    func createBackButton() {
        exitButton = SKSpriteNode(imageNamed: "back")
        exitButton?.position = CGPoint(x: 40, y: frame.maxY - 50)
        exitButton?.zPosition = 2
        exitButton?.name = "back"
        addChild(exitButton!)
    }
    
    func loadBallColorsLabels() {
        let node1 = SKSpriteNode(imageNamed: "playerGreen")
        node1.position = CGPoint(x: frame.maxX / 2 - 90, y: frame.maxY / 2 + 50 )
        addChild(node1)
        node1.size = CGSize(width: 60, height: 60)
        node1.name = "playerGreen"
        ballColors.append(node1)
        
        let node2 = SKSpriteNode(imageNamed: "playerBlue")
        node2.position = CGPoint(x: frame.maxX / 2, y: frame.maxY / 2 + 50)
        addChild(node2)
        node2.size = CGSize(width: 60, height: 60)
        node2.name = "playerBlue"
        ballColors.append(node2)
        
        let node3 = SKSpriteNode(imageNamed: "playerPink")
        node3.position = CGPoint(x: frame.maxX / 2 + 90, y: frame.maxY / 2 + 50)
        addChild(node3)
        node3.size = CGSize(width: 60, height: 60)
        node3.name = "playerPink"
        ballColors.append(node3)
    }
    
    func selectNew(color: String) {
        userDefaults.set(color, forKey: "ballColor")
        
        ballColors.forEach { (node) in
            if node.name == color {
                selectedColor?.position = node.position
                return
            }
        }
    }
    
    func loadComplexityLevelLabels() {
        let node1 = SKSpriteNode(imageNamed: "easy")
        node1.position = CGPoint(x: frame.maxX / 2 - 90, y: frame.maxY / 3 )
        addChild(node1)
        node1.size = CGSize(width: 60, height: 60)
        node1.name = "easy"
        complexityLevels.append(node1)
        
        let node2 = SKSpriteNode(imageNamed: "medium")
        node2.position = CGPoint(x: frame.maxX / 2, y: frame.maxY / 3)
        addChild(node2)
        node2.size = CGSize(width: 60, height: 60)
        node2.name = "medium"
        complexityLevels.append(node2)
        
        let node3 = SKSpriteNode(imageNamed: "hard")
        node3.position = CGPoint(x: frame.maxX / 2 + 90, y: frame.maxY / 3)
        addChild(node3)
        node3.size = CGSize(width: 60, height: 60)
        node3.name = "hard"
        complexityLevels.append(node3)
    }
    
    func selectNew(complexityLevel: String) {
        userDefaults.set(complexityLevel, forKey: Constants.complexityLevel)
        
        complexityLevels.forEach { (node) in
            if node.name == complexityLevel {
                selectedLevel?.position = node.position
                return
            }
        }
    }
    
    func createSelectedLevelButton() {
        
        let complexityLevel: String = userDefaults.string(forKey: Constants.complexityLevel) ?? "medium"

        complexityLevels.forEach { (node) in
            if node.name == complexityLevel {
                print("Select level")
                selectedLevel = SKSpriteNode(imageNamed: "circle")
                selectedLevel?.size = CGSize(width: 85, height: 85)
                selectedLevel?.position = node.position
                selectedLevel?.zPosition = 3
                selectedLevel?.name = "selectedColor"
                addChild(selectedLevel!)
                
                return
            }
        }
    }
}

extension SettingsScene: SKPhysicsContactDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        
        let frontTouchedNode = atPoint(location).name
        
        if frontTouchedNode == "back" {
            settingsDelegate?.downloadMainMenu()
        } else if frontTouchedNode == "playerGreen" {
            selectNew(color: "playerGreen")
        } else if frontTouchedNode == "playerBlue" {
            selectNew(color: "playerBlue")
        } else if frontTouchedNode == "playerPink" {
            selectNew(color: "playerPink")
        } else if frontTouchedNode == "easy" {
            selectNew(complexityLevel: "easy")
        } else if frontTouchedNode == "medium" {
            selectNew(complexityLevel: "medium")
        } else if frontTouchedNode == "hard" {
            selectNew(complexityLevel: "hard")
        }
    }
}


