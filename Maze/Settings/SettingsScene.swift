//
//  SettingsScene.swift
//  Maze
//
//  Created by Иван Абрамов on 14.11.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import Foundation
import SpriteKit

class SettingsScene: SKScene {
    
    override func didMove(to view: SKView) {
        loadBackground(forView: view)
    }
    
    func loadBackground(forView view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: view.center.x, y: view.center.y)
        background.blendMode = .replace
        background.zPosition = -1
        background.size = CGSize (width: frame.maxX, height: frame.maxY)
        
        addChild(background)
    }
}
