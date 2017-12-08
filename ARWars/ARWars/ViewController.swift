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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private var tieFighter: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTieFigher()
        
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        
        addNewTieFigher()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        shoot()
    }
    
    
    private func shoot() {
        let node = SCNNode()
        
        let sphere = SCNSphere(radius: 0.025)
        node.geometry = sphere
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        node.physicsBody?.isAffectedByGravity = false
        
        let (direction, position) = self.getUserVector()
        node.position = position // SceneKit/AR coordinates are in meters
        
        let bulletDirection = direction
        node.physicsBody?.applyForce(bulletDirection, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(node)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            node.removeFromParentNode()
        }
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let speed:Float = -5
            let dir = SCNVector3(speed * mat.m31, speed * mat.m32, speed * mat.m33) // orientation of camera in world space
            
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    private var fighterClone: SCNNode?
    
    func addNewTieFigher() {
        self.fighterClone?.removeFromParentNode()
        if let fighter = tieFighter?.clone() {
            let posX = floatBetween(-1, and: 1)
            let posY = floatBetween(-1, and: 1)
            fighter.position = SCNVector3(posX, posY, -1) // SceneKit/AR coordinates are in meters
            sceneView.scene.rootNode.addChildNode(fighter)
            self.fighterClone = fighter
        }
    }
    
    func loadTieFigher() {
        if let scene = SCNScene(named: "art.scnassets/Tie.scn") {
            tieFighter = scene.rootNode.childNodes[0]
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
