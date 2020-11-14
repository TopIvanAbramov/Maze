//
//  GameScene.swift
//  Maze
//
//  Created by Иван Абрамов on 09.11.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

protocol GameDelegate {
    func generateNewMap(height: Int, width: Int)
    func downloadMainMenu()
}

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
}

enum GameState {
    case gameOver
    case nextLevel
    case play
    case pause
}

class GameScene: SKScene, SKPhysicsContactDelegate, LoadMapDelegate {
    
    func generated(map: String) {
        self.currentMap = map
        loadScoreLabels()
        loadLevel(fromString: map)
    }
    
    
    private var backgroundNode: SKSpriteNode?
    private var lightNode: SKLightNode = SKLightNode()
    private var playerPosition: CGPoint?
    private var cellWidth : CGFloat = 0.0
    private var xOffset : CGFloat = 0.0
    private var motionManager: CMMotionManager?
    private var pauseButton: SKNode!
    private var playAgainButton: SKLabelNode!
    private var mainMenuButton: SKLabelNode!
    private var nextLevelButton: SKLabelNode!
    private var playerNode: SKSpriteNode!
    private var gameState: GameState = .play {
        didSet {
            stateChanged(to: gameState)
        }
    }
    private var removedNodes: [SKNode] = []
    private var scoreNodes: [SKNode] = []
    var mapDelegate: GameDelegate?
    
    private var currentMap: String?
    
    private var score = 0 {
        didSet {
            updateScoreLabel(withScore: score)
        }
    }
    
    override func didMove(to view: SKView) {
        
        
        mapDelegate?.generateNewMap(height: Constants.numberOfCellsHeight, width: Constants.numberOfCellsWidth)
        
        cellWidth = (UIScreen.main.bounds.height) / CGFloat(Constants.numberOfCellsHeight)
        xOffset = (frame.maxX - CGFloat(Constants.numberOfCellsWidth) * cellWidth) / 2
    
        physicsWorld.contactDelegate = self
        
//        loadLightNode()
        createMainMenuButton()
        setupPauseButton()
        createReplayButton()
        createNextlevelButton()
        loadBackground(forView: view)
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    
    func loadLevel(fromString map: String) {
        let lines = map.split(separator: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (cellWidth * CGFloat(column)) + xOffset + 32,
                                       y: (cellWidth * CGFloat(row)) + 23)
                
                switch letter {
                case "x":
                    loadWall(withPosition: position)
                case "v":
                    loadVortex(withPosition: position)
                case "s":
                    loadStar(withPosition: position)
                case "f":
                    loadFinishPoint(withPosition: position)
                case "i":
                    loadPlayer(withPosition: position)
                case " ":
                    break
                default:
                    fatalError("Unknown symbol")
                }
            }
        }
    }
    
//    func loadWall(withPosition position: CGPoint) {
//        let node = SKSpriteNode(imageNamed: "block")
//        node.position = position
//        node.name = "block"
//
//        node.size = CGSize(width: cellWidth, height: cellWidth)
//        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
//        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
//        node.physicsBody?.isDynamic = false
//
//        node.lightingBitMask = 0b0001
//        node.shadowCastBitMask = 0b0001
//
////        node.blendMode = .alpha
////        node.colorBlendFactor = 1
////        node.color = .black
////        node.alpha = 0.25
//
//        addChild(node)
//    }
    
    func loadStar(withPosition position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "star")
        node.position = position
        node.name = "star"
        
        node.size = CGSize(width: cellWidth, height: cellWidth)
         node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.isDynamic = false
        addChild(node)
    }
    
    func loadVortex(withPosition position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.position = position
        node.name = "vortex"
        
        node.size = CGSize(width: cellWidth, height: cellWidth)
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.isDynamic = false
        
        let oneRevolution:SKAction = SKAction.rotate(byAngle: -.pi, duration: 1)
        let repeatRotation:SKAction = SKAction.repeatForever(oneRevolution)
        
        node.run(repeatRotation)
        
        addChild(node)
    }
    
    func loadFinishPoint(withPosition position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.position = position
        node.name = "finish"
        
        node.size = CGSize(width: cellWidth, height: cellWidth)
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.isDynamic = false
        addChild(node)
    }
    
    func loadPlayer(withPosition position: CGPoint) {
        self.playerPosition = position
        playerNode = SKSpriteNode(imageNamed: "player")
        playerNode.position = position
        
        playerNode.name = "player"
        playerNode.zPosition = 1
        
//        node.size = CGSize(width: cellWidth, height: cellWidth)
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerNode.size.width / 2)
        playerNode.physicsBody?.allowsRotation = false
        playerNode.physicsBody?.linearDamping = 0.5
        playerNode.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        playerNode.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        playerNode.physicsBody?.contactTestBitMask = CollisionTypes.finish.rawValue |
                                               CollisionTypes.star.rawValue |
                                               CollisionTypes.vortex.rawValue
        playerNode.physicsBody?.isDynamic = true
        
        loadLightNode()
        addChild(playerNode)
    }
    
    func setupPauseButton() {
        pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton?.position = CGPoint(x: 40, y: frame.maxY - 50)
        pauseButton?.zPosition = 3
        pauseButton.name = "pauseButton"
        addChild(pauseButton)
    }
    
//  MARK:- Create menu buttons
    
    func createMainMenuButton() {
           self.mainMenuButton = SKLabelNode(fontNamed: "Apple SD Gothic Neo Bold")
           self.mainMenuButton.position = CGPoint(x: self.frame.maxX / 2,
                                              y: self.frame.maxY / 2 - 70)
           
           self.mainMenuButton.name = "mainMenu"
           self.mainMenuButton.zPosition = 3
           
           self.mainMenuButton.text = "Main menu"
           let background = SKShapeNode(rect: CGRect(x: -mainMenuButton.frame.size.width / 2 - 23,
                                                     y: -12,
                                                     width: 200,
                                                     height: 50),
                                                     cornerRadius: 10)
           
           
           background.fillColor = #colorLiteral(red: 0.9803921569, green: 0.737254902, blue: 0.2392156863, alpha: 1)
           self.mainMenuButton.addChild(background)

           background.zPosition = 0
           background.name = "mainMenu"
           background.isUserInteractionEnabled = false
       }
    
    func createReplayButton() {
        self.playAgainButton = SKLabelNode(fontNamed: "Apple SD Gothic Neo Bold")
        self.playAgainButton.position = CGPoint(x: self.frame.maxX / 2,
                                           y: self.frame.maxY / 2 + 70)
        
        self.playAgainButton.name = "mainButton"
        self.playAgainButton.zPosition = 3
        
        self.playAgainButton.text = "Play again ↻"
        let background = SKShapeNode(rect: CGRect(x: -playAgainButton.frame.size.width / 2 - 15,
                                                  y: -12,
                                                  width: 200,
                                                  height: 50),
                                                  cornerRadius: 10)
        
        
        background.fillColor = #colorLiteral(red: 0.9803921569, green: 0.737254902, blue: 0.2392156863, alpha: 1)
        self.playAgainButton.addChild(background)

        background.zPosition = 0
        background.name = "mainButton"
        background.isUserInteractionEnabled = false
    }
    
    func createNextlevelButton() {
        self.nextLevelButton = SKLabelNode(fontNamed: "Apple SD Gothic Neo Bold")
        self.nextLevelButton.position = CGPoint(x: self.frame.maxX / 2,
                                           y: self.frame.maxY / 2)
        
        self.nextLevelButton.name = "playNextLevel"
        self.nextLevelButton.zPosition = 3
        
        self.nextLevelButton.text = "Next level ❯"
        let background = SKShapeNode(rect: CGRect(x: -playAgainButton.frame.size.width / 2 - 15,
                                                  y: -12,
                                                  width: 200,
                                                  height: 50),
                                                  cornerRadius: 10)
        
        
        background.fillColor = .systemRed
        self.nextLevelButton.addChild(background)

        background.zPosition = 0
        background.name = "playNextLevel"
        background.isUserInteractionEnabled = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let accelerometerData = motionManager?.accelerometerData else { return }
        physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * 50,
                                        dy: accelerometerData.acceleration.x * -50)
        
        guard let playerNode = playerNode else {
            return
        }
        
        
        lightNode.position = playerNode.position
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let bodyA = contact.bodyA.node else { return }
        guard let bodyB = contact.bodyB.node else { return }
        
        if bodyA.name == "player" {
            self.playerCollided(withNode: bodyB)
        } else if bodyB.name == "player" {
            self.playerCollided(withNode: bodyA)
        }
    }
    
    func playerCollided(withNode node: SKNode) {
        switch node.name {
        case "star":
            removedNodes.append(node)
            node.removeFromParent()
            score += 1
        case "vortex":
            
            guard gameState == .play else { return }
            gameState = .pause
                
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(by : 0.001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            
            let sequnce = SKAction.sequence([move, scale, remove])
            
            playerNode.run(sequnce) {
                guard self.score - 1 >= 0 else {
//                    self.gameState = .pause
                    self.playerNode.physicsBody?.isDynamic = false
                    
                    self.addChild(self.playAgainButton)
                    self.addChild(self.nextLevelButton)
                    self.addChild(self.mainMenuButton)
                    
                    return
                }
                self.score -= 1
                
                self.gameState = .play
                self.loadPlayer(withPosition: self.playerPosition!)
            }
        case "finish":
            gameState = .nextLevel
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(by : 0.001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            
            let sequnce = SKAction.sequence([move, scale, remove])
            
            playerNode.run(sequnce) {
                self.playerNode.physicsBody?.isDynamic = false
                
                guard let sparkNode = SKEmitterNode(fileNamed: "Spark") else { return }
                sparkNode.position = CGPoint(x: self.frame.maxX / 2,
                                              y: self.frame.maxY / 2)
                self.addChild(sparkNode)
                
                
                let scale = SKAction.scale(by : 0.001, duration: 3.0)
                let remove = SKAction.removeFromParent()
                
                let secondSequnce = SKAction.sequence([scale, remove])
                
                sparkNode.run(secondSequnce) {
                    self.addChild(self.playAgainButton)
                    self.addChild(self.nextLevelButton)
                }
            }
        default:
            break
        }
    }
    
    
    func loadBackground(forView view: SKView) {
        backgroundNode = SKSpriteNode(imageNamed: "background")
        backgroundNode?.position = CGPoint(x: view.center.x, y: view.center.y)
        backgroundNode?.blendMode = .replace
        backgroundNode?.zPosition = -1
        backgroundNode?.size = CGSize (width: frame.maxX, height: frame.maxY)
        
//        background.lightingBitMask = 0b0001
        
        addChild(backgroundNode!)
    }
    
    
    func addRemovedNodes() {
        removedNodes.forEach { node in
            addChild(node)
        }
    }
    
    func removeAllGameNode() {
        self.children.forEach({ (node) in
            if ["star", "block", "player", "vortex", "finish"].contains(node.name) {
                node.removeFromParent()
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        
        let frontTouchedNode = atPoint(location).name
        
        if frontTouchedNode == "mainButton" {
            
            gameState = .play
            
            if gameState == .pause {
                playAgainButton.removeFromParent()
                nextLevelButton.removeFromParent()
                backgroundNode?.zPosition = -1
            }
            
//            addRemovedNodes()
            removedNodes = []
            score = 0
            playAgainButton.removeFromParent()
            nextLevelButton.removeFromParent()
            mainMenuButton.removeFromParent()
            
            gameState = .play
            
            removeAllGameNode()
            
            addRemovedNodes()
            
            loadLevel(fromString: self.currentMap!)
        } else if frontTouchedNode == "playNextLevel" {
            
            if gameState == .pause {
                playAgainButton.removeFromParent()
                nextLevelButton.removeFromParent()
                mainMenuButton.removeFromParent()
                
                backgroundNode?.zPosition = -1
            }
            
            gameState = .play
            
            removedNodes = []
            score = 0
            playAgainButton.removeFromParent()
            nextLevelButton.removeFromParent()
            mainMenuButton.removeFromParent()
            
            gameState = .play
            
            removeAllGameNode()
            
            mapDelegate?.generateNewMap(height: Constants.numberOfCellsHeight, width: Constants.numberOfCellsWidth)
        } else if frontTouchedNode == "pauseButton" {
            
            guard  gameState == .play else { return }
            gameState = .pause
            
            backgroundNode?.zPosition = 2
            addChild(playAgainButton)
            addChild(nextLevelButton)
            addChild(mainMenuButton)
            
            let touchedNodes = nodes(at: location)
            let node = touchedNodes.first { (node) -> Bool in
                node.name == "pauseButton"
            }
            node?.run(.setTexture(SKTexture(imageNamed: "play")))
            node?.name = "playButton"
            
            playerNode.physicsBody?.isDynamic = false
            
        } else if frontTouchedNode == "playButton" {
            
            gameState = .play
            
            backgroundNode?.zPosition = -1
            playAgainButton.removeFromParent()
            nextLevelButton.removeFromParent()
            
            let touchedNodes = nodes(at: location)
            let node = touchedNodes.first { (node) -> Bool in
                node.name == "playButton"
            }
            node?.run(.setTexture(SKTexture(imageNamed: "pause")))
            node?.name = "pauseButton"
            
            playerNode.physicsBody?.isDynamic = true
        } else if frontTouchedNode == "mainMenu" {
            mapDelegate?.downloadMainMenu()
        }
    }
    
    func loadWall(withPosition position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position
        node.name = "block"
        
        node.size = CGSize(width: cellWidth, height: cellWidth)
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false
        
        node.lightingBitMask = 0b0001
        node.shadowCastBitMask = 0b0001
        
//        node.blendMode = .alpha
//        node.colorBlendFactor = 1
//        node.color = .black
//        node.alpha = 0.25
        
        addChild(node)
    }
    
    func loadLightNode() {
//        lightNode = SKLightNode()
//        lightNode.position = position
//        lightNode.categoryBitMask = 0b0001
//        lightNode.lightColor = .white
        
//        let lightNode2 = SKLightNode()
//        lightNode2.position = CGPoint(x: frame.maxX / 2, y: frame.maxY / 2)
//        lightNode2.categoryBitMask = 0b0011
//        lightNode2.lightColor = .white
//
//        lightNode2.ambientColor = .white
//
//        lightNode2.zPosition = 4
//        self.addChild(lightNode2)
        
    }
    
        func loadScoreLabels() {
            let node1 = SKSpriteNode(imageNamed: "star_unselected")
            node1.position = CGPoint(x: 40, y: frame.maxY / 2 + 50 )
            addChild(node1)
            node1.size = CGSize(width: 35, height: 35)
            scoreNodes.append(node1)
            
            let node2 = SKSpriteNode(imageNamed: "star_unselected")
            node2.position = CGPoint(x: 40, y: frame.maxY / 2)
            addChild(node2)
            node2.size = CGSize(width: 35, height: 35)
            scoreNodes.append(node2)
            
            let node3 = SKSpriteNode(imageNamed: "star_unselected")
            node3.position = CGPoint(x: 40, y: frame.maxY / 2 - 50)
            addChild(node3)
            node3.size = CGSize(width: 35, height: 35)
            scoreNodes.append(node3)
        }
    
    func updateScoreLabel(withScore score: Int) {
        for i in 0...2 {
            print(i)
            if i < score {
                scoreNodes[i].run(.setTexture(SKTexture(imageNamed: "star")))
            } else {
                scoreNodes[i].run(.setTexture(SKTexture(imageNamed: "star_unselected")))
            }
        }
    }
    
    func stateChanged(to state: GameState) {
        print("State: \(state)")
    }
}
