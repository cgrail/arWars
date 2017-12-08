//
//  ViewController.swift
//  ARWars
//
//  Created by Grail, Christian on 07.12.17.
//  Copyright © 2017 SAP Se. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private var tieFighter: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTieFigher()
        
        sceneView.scene = SCNScene()
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.autoenablesDefaultLighting = true
        
        addNewTieFigher()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        shoot()
    }
    
    private func shoot() {
        
        playSoundEffect(ofType: .laser)
        
        let node = SCNNode()
        
        let box = SCNBox(width: 0.1, height: 0.1, length: 1, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor.red
        box.firstMaterial?.lightingModel = .constant
        
        node.geometry = box
        node.opacity = 0.5

        let shape = SCNPhysicsShape(geometry: box, options: nil)
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.categoryBitMask = CollisionCategory.laser.rawValue
        node.physicsBody?.contactTestBitMask = CollisionCategory.fighter.rawValue
        
        if let pov = sceneView.pointOfView {
            node.position = pov.position
            
            node.eulerAngles = pov.eulerAngles
        }
        
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let speed:Float = -5
            let dir = SCNVector3(speed * mat.m31, speed * mat.m32, speed * mat.m33) // orientation of camera in world space
            node.physicsBody?.applyForce(dir, asImpulse: true)
        }
        
        sceneView.scene.rootNode.addChildNode(node)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            node.removeFromParentNode()
        }
    }
    
    private var fighterClone: SCNNode?
    
    func addNewTieFigher() {
        self.fighterClone?.removeFromParentNode()
        if let fighter = tieFighter?.clone() {
            let posX = floatBetween(-1, and: 1)
            let posY = floatBetween(-1, and: 1)
            var targetPos = SCNVector3(posX, posY, -10)
            fighter.position = targetPos

            fighter.physicsBody = SCNPhysicsBody.dynamic()
            fighter.physicsBody?.isAffectedByGravity = false

            fighter.physicsBody?.categoryBitMask = CollisionCategory.fighter.rawValue
            fighter.physicsBody?.contactTestBitMask = CollisionCategory.laser.rawValue
            
            targetPos.z = -1
            let action = SCNAction.move(to: targetPos, duration: 1)
            action.timingMode = .easeInEaseOut
            fighter.runAction(action)
            fighter.opacity = 0
            fighter.runAction(SCNAction.fadeOpacity(to: 1, duration: 1))

            sceneView.scene.rootNode.addChildNode(fighter)
            self.fighterClone = fighter
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.fighter.rawValue || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.fighter.rawValue {
            
            self.playSoundEffect(ofType: .explosion)
            
            let particleSystem = SCNParticleSystem(named: "Explode", inDirectory: nil)
            let systemNode = SCNNode()
            systemNode.addParticleSystem(particleSystem!)
            systemNode.position = contact.nodeA.position
            sceneView.scene.rootNode.addChildNode(systemNode)
            
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.addNewTieFigher()
            })
        }
    }
    
    func loadTieFigher() {
        if let scene = SCNScene(named: "art.scnassets/Tie.scn") {
            tieFighter = scene.rootNode.childNodes[0]
        }
    }
    
    private var player: AVAudioPlayer?
    
    enum SoundEffect: String {
        case laser = "Laser"
        case explosion = "Explosion"
    }
    
    func playSoundEffect(ofType effect: SoundEffect) {
        
        // Async to avoid substantial cost to graphics processing (may result in sound effect delay however)
        DispatchQueue.main.async {
            do
            {
                if let effectURL = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3") {
                    
                    self.player = try AVAudioPlayer(contentsOf: effectURL)
                    self.player?.play()
                    
                }
            }
            catch let error as NSError {
                print(error.description)
            }
        }
    }
    
    func floatBetween(_ first: Float,  and second: Float) -> Float { // random float between upper and lower bound (inclusive)
        return (Float(arc4random()) / Float(UInt32.max)) * (first - second) + second
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let laser  = CollisionCategory(rawValue: 1 << 0) // 00...01
    static let fighter = CollisionCategory(rawValue: 1 << 1) // 00..10
}
