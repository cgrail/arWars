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
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.addNewTieFigher()
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
