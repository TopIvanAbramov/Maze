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

protocol RequestMapDelegate {
    func generateNewMap(height: Int, width: Int)
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
}

class GameScene: SKScene, SKPhysicsContactDelegate, LoadMapDelegate {
    
    func generated(map: String, withX x: Int, andY y: Int) {
        self.currentMap = map
        self.currentX = x
        self.currentY = y
        
        loadLevel(fromString: map, withX: x, andY: x)
        createPlayer(withX: x, andY: y)
    }
    
    
    private var cellWidth : CGFloat = 0.0
    private var xOffset : CGFloat = 0.0
    private var motionManager: CMMotionManager?
    private var scoreLabel: SKLabelNode!
    private var mainButton: SKLabelNode!
    private var nextLevelButton: SKLabelNode!
    private var playerNode: SKSpriteNode!
    private var gameState: GameState = .play
    private var removedNodes: [SKNode] = []
    var mapDelegate: RequestMapDelegate?
    
    var currentMap: String?
    var currentX = 1
    var currentY = 1
    
    private var score = 0 {
        didSet {
            scoreLabel?.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        
        cellWidth = (UIScreen.main.bounds.height) / CGFloat(Constants.numberOfCellsHeight)
        xOffset = (frame.maxX - CGFloat(Constants.numberOfCellsWidth) * cellWidth) / 2
    
        physicsWorld.contactDelegate = self
        
        setupScoreLabel()
        createMainButton()
        createNextlevelButton()
        loadBackground(forView: view)
        
        physicsWorld.gravity = .zero
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    
    func loadLevel(fromString map: String, withX x: Int, andY y: Int) {
        let lines = map.split(separator: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (cellWidth * CGFloat(column)) + xOffset + 82,
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
                case " ":
                    break
                default:
                    fatalError("Unknown symbol")
                }
            }
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
        addChild(node)
    }
    
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
    
    func createPlayer(withX x: Int, andY y: Int) {
        playerNode = SKSpriteNode(imageNamed: "player")
        playerNode.position = CGPoint(x: (cellWidth * CGFloat(x)) + xOffset + 82,
                                      y: (cellWidth * CGFloat(Constants.numberOfCellsHeight - y - 2)) + 32)
        
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
        addChild(playerNode)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel?.position = CGPoint(x: 100, y: frame.maxY - 50)
        scoreLabel?.zPosition = 2
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let accelerometerData = motionManager?.accelerometerData else { return }
        physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * 50,
                                        dy: accelerometerData.acceleration.x * -50)
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
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(by : 0.001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            
            let sequnce = SKAction.sequence([move, scale, remove])
            
            playerNode.run(sequnce) {
//                self.removedNodes.append(node)
                guard self.score - 1 >= 0 else {
                    self.gameState = .gameOver
                    self.playerNode.physicsBody?.isDynamic = false
                    
                    self.addChild(self.mainButton)
                    self.addChild(self.nextLevelButton)
                    
                    return
                }
                self.score -= 1
                
                self.createPlayer(withX: self.currentX, andY: self.currentY)
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
                    self.addChild(self.mainButton)
                    self.addChild(self.nextLevelButton)
                }
            }
        default:
            break
        }
    }
    
    func createMainButton() {
        self.mainButton = SKLabelNode(fontNamed: "Chalkduster")
        self.mainButton.position = CGPoint(x: self.frame.maxX / 2,
                                           y: self.frame.maxY / 2)
        
        self.mainButton.name = "mainButton"
        self.mainButton.zPosition = 3
        
        self.mainButton.text = "Play again ↻"
        let background = SKShapeNode(rect: CGRect(x: -mainButton.frame.size.width / 2,
                                                  y: -10,
                                                  width: 250,
                                                  height: 50),
                                                  cornerRadius: 10)
        
        
        background.fillColor = .systemYellow
        self.mainButton.addChild(background)

        background.zPosition = 0
        background.name = "mainButton"
        background.isUserInteractionEnabled = false
    }
    
    func createNextlevelButton() {
        self.nextLevelButton = SKLabelNode(fontNamed: "Chalkduster")
        self.nextLevelButton.position = CGPoint(x: self.frame.maxX / 2,
                                           y: self.frame.maxY / 3)
        
        self.nextLevelButton.name = "playNextLevel"
        self.nextLevelButton.zPosition = 3
        
        self.nextLevelButton.text = "Next level ❯"
        let background = SKShapeNode(rect: CGRect(x: -mainButton.frame.size.width / 2,
                                                  y: -10,
                                                  width: 250,
                                                  height: 50),
                                                  cornerRadius: 10)
        
        
        background.fillColor = .systemRed
        self.nextLevelButton.addChild(background)

        background.zPosition = 0
        background.name = "playNextLevel"
        background.isUserInteractionEnabled = false
    }
    
    func loadBackground(forView view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: view.center.x, y: view.center.y)
        background.blendMode = .replace
        background.zPosition = -1
        background.size = CGSize (width: frame.maxX, height: frame.maxY)
        
        addChild(background)
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
//            addRemovedNodes()
            removedNodes = []
            score = 0
            mainButton.removeFromParent()
            nextLevelButton.removeFromParent()
            gameState = .play
            
            removeAllGameNode()
            
            addRemovedNodes()
            
            loadLevel(fromString: self.currentMap!, withX: 0, andY: 0)
            createPlayer(withX: self.currentX, andY: self.currentY)
//            mapDelegate?.generateNewMap(height: Constants.numberOfCellsHeight, width: Constants.numberOfCellsWidth)
        } else if frontTouchedNode == "playNextLevel" {
//            addRemovedNodes()
            removedNodes = []
            score = 0
            mainButton.removeFromParent()
            nextLevelButton.removeFromParent()
            gameState = .play
            
            removeAllGameNode()
            
            mapDelegate?.generateNewMap(height: Constants.numberOfCellsHeight, width: Constants.numberOfCellsWidth)
        }
    }
}