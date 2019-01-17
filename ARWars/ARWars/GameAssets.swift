//
//  GameAssets.swift
//  ARWars
//
//  Created by Grail, Christian on 17.01.19.
//  Copyright © 2019 SAP Se. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class GameAssets: NSObject {

    public enum SoundEffect: String {
        case laser = "Laser"
        case explosion = "Explosion"
    }

    public var tieFighter: SCNNode = SCNScene(named: "art.scnassets/Tie.scn")!.rootNode.childNodes[0]

    private var audioPlayers = Set<AVAudioPlayer>()

    public func playSoundEffect(ofType effect: SoundEffect) {
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

extension GameAssets: AVAudioPlayerDelegate{

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayers.remove(player)
    }
}

struct CollisionCategory: OptionSet {
    public let rawValue: Int

    public static let laser  = CollisionCategory(rawValue: 1 << 0)
    public static let fighter = CollisionCategory(rawValue: 1 << 1)
}
