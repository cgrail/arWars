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

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, AVAudioPlayerDelegate {

    enum SoundEffect: String {
        case laser = "Laser"
        case explosion = "Explosion"
    }

    @IBOutlet var sceneView: ARSCNView!

    private var tieFighter: SCNNode = SCNScene(named: "art.scnassets/Tie.scn")!.rootNode.childNodes[0]
    private var fighterClone: SCNNode?
    private var audioPlayers = Set<AVAudioPlayer>()

    // MARK: - Controller Life Cycle

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
        shoot()
    }

    // MARK: - SCNPhysicsContactDelegate

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.fighter.rawValue
            || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.fighter.rawValue else { return }

        playSoundEffect(ofType: .explosion)

        let particleSystem = SCNParticleSystem(named: "Explode", inDirectory: nil)!
        let systemNode = SCNNode()
        systemNode.addParticleSystem(particleSystem)
        systemNode.position = contact.nodeA.position
        sceneView.scene.rootNode.addChildNode(systemNode)

        contact.nodeA.removeFromParentNode()
        contact.nodeB.removeFromParentNode()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.addNewTieFigher()
        }
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayers.remove(player)
    }

    // MARK: - Private Methods

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
            let matrix = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let speed: Float = -5
            let direction = SCNVector3(speed * matrix.m31, speed * matrix.m32, speed * matrix.m33) // orientation of camera in world space
            node.physicsBody?.applyForce(direction, asImpulse: true)
        }

        sceneView.scene.rootNode.addChildNode(node)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            node.removeFromParentNode()
        }
    }

    private func addNewTieFigher() {
        self.fighterClone?.removeFromParentNode()
        let fighter = tieFighter.clone()
        let posX = Float.random(in: -1...1)
        let posY = Float.random(in: -1...1)
        var targetPosition = SCNVector3(posX, posY, -10)
        fighter.position = targetPosition

        fighter.physicsBody = SCNPhysicsBody.dynamic()
        fighter.physicsBody?.isAffectedByGravity = false

        fighter.physicsBody?.categoryBitMask = CollisionCategory.fighter.rawValue
        fighter.physicsBody?.contactTestBitMask = CollisionCategory.laser.rawValue

        targetPosition.z = -1
        let action = SCNAction.move(to: targetPosition, duration: 1)
        action.timingMode = .easeInEaseOut
        fighter.runAction(action)
        fighter.opacity = 0
        fighter.runAction(SCNAction.fadeOpacity(to: 1, duration: 1))

        sceneView.scene.rootNode.addChildNode(fighter)
        self.fighterClone = fighter
    }

    private func playSoundEffect(ofType effect: SoundEffect) {
        let player: AVAudioPlayer
        switch effect {
        case .explosion: player = playerForSoundEffect(.explosion)
        case .laser: player = playerForSoundEffect(.laser)
        }

        player.play()
        audioPlayers.insert(player)
    }

    private func playerForSoundEffect(_ soundEffect: SoundEffect) -> AVAudioPlayer {
        let player = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: soundEffect.rawValue, withExtension: "mp3")!)
        player.delegate = self
        return player
    }

}

struct CollisionCategory: OptionSet {
    let rawValue: Int

    static let laser  = CollisionCategory(rawValue: 1 << 0)
    static let fighter = CollisionCategory(rawValue: 1 << 1)
}
