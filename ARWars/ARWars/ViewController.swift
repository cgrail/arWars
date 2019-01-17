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

    private var assets = GameAssets()

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.scene = SCNScene()
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.autoenablesDefaultLighting = true

        addNewTieFigher()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let laser = createLaser()
        addPhysics(laser)
        applyForce(laser)
        assets.playSoundEffect(ofType: .laser)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            laser.removeFromParentNode()
        }
    }

    private func createLaser() -> SCNNode {

        let node = SCNNode()

        let box = SCNBox(width: 0.1, height: 0.1, length: 2, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor.red
        box.firstMaterial?.lightingModel = .constant

        node.geometry = box
        node.opacity = 0.5

        if let pov = sceneView.pointOfView {
            node.position = pov.position
            node.position.y -= 0.3
            node.eulerAngles = pov.eulerAngles
        }

        sceneView.scene.rootNode.addChildNode(node)

        return node
    }

    private func addPhysics(_ laser: SCNNode) {
        let shape = SCNPhysicsShape(geometry: laser.geometry!, options: nil)
        laser.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        laser.physicsBody?.isAffectedByGravity = false
        laser.physicsBody?.categoryBitMask = CollisionCategory.laser.rawValue
        laser.physicsBody?.contactTestBitMask = CollisionCategory.fighter.rawValue
        laser.physicsBody?.collisionBitMask = CollisionCategory.fighter.rawValue
    }

    private func applyForce(_ laser:SCNNode) {
        guard let frame = self.sceneView.session.currentFrame else {
            return
        }
        let matrix = SCNMatrix4(frame.camera.transform)
        let speed: Float = -5
        let direction = SCNVector3(speed * matrix.m31, speed * matrix.m32, speed * matrix.m33)
        laser.physicsBody?.applyForce(direction, asImpulse: true)
    }

    private func addNewTieFigher() {
        let fighter = assets.tieFighter.clone()
        let posX = Float.random(in: -1...1)
        let posY = Float.random(in: -1...1)
        fighter.position = SCNVector3(posX, posY, -10)

        fighter.physicsBody = SCNPhysicsBody.dynamic()
        fighter.physicsBody?.isAffectedByGravity = false

        fighter.physicsBody?.categoryBitMask = CollisionCategory.fighter.rawValue
        fighter.physicsBody?.contactTestBitMask = CollisionCategory.laser.rawValue

        sceneView.scene.rootNode.addChildNode(fighter)
        animateFighter(fighter)

    }

    private func animateFighter(_ fighter: SCNNode) {
        var targetPosition = fighter.position
        targetPosition.z = -1
        let action = SCNAction.move(to: targetPosition, duration: 1)
        action.timingMode = .easeInEaseOut
        fighter.runAction(action)
        fighter.opacity = 0
        fighter.runAction(SCNAction.fadeOpacity(to: 1, duration: 1))
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.fighter.rawValue
            || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.fighter.rawValue else { return }
        contact.nodeA.removeFromParentNode()
        contact.nodeB.removeFromParentNode()
        assets.playSoundEffect(ofType: .explosion)
        createExplosion(contact.nodeA.position)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.addNewTieFigher()
        }
    }

    private func createExplosion(_ postion: SCNVector3) {
        let particleSystem = SCNParticleSystem(named: "Explode", inDirectory: nil)!
        let systemNode = SCNNode()
        systemNode.addParticleSystem(particleSystem)
        systemNode.position = postion
        sceneView.scene.rootNode.addChildNode(systemNode)
    }

}
