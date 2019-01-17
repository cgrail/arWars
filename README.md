# ArWars

A small example project I've live coded at the Google Developer Group conference DevFest 2017 in Karlsruhe Germany. 

http://www.devfestka.de/programm

It is based on ARKit and demonstrates general 3D development basics, SceneKit, loading 3D Models, the PhysicsEngine and the AVAudioPlayer.

## Step by Step Guide

Checkout commit ["Initial version"](https://github.com/cgrail/arWars/tree/initialVersion) 

### [Step 1: Create laser](https://github.com/cgrail/arWars/commit/bab6a9c568155e8466d57390c8e32206edb3bc31)

```swift
 override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      let laser = createLaser()
  }
```

See: 

### [Step 2: Add physics and animate laser](https://github.com/cgrail/arWars/commit/d8da99443f372867cb8cb8762e7c141d0392815a)

```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  ...
  addPhysics(laser)
  animateLaser(laser)
}
```

### [Step 3: Play laser sound](https://github.com/cgrail/arWars/commit/2547cb1f04b890de450d38058cee493b251338a7)

```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  ...
  assets.playSoundEffect(ofType: .laser)
}
```

### [Step 4: Make laser disappear after 1 second](https://github.com/cgrail/arWars/commit/f63f933790403853f7df3808bc3ceccb9e7b3c03)

```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  ...
  DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      laser.removeFromParentNode()
  }
}
```

### [Step 5: Add new TIE Fighter](https://github.com/cgrail/arWars/commit/7e770ec4836305a94c5bbd2556b89312a6766918)

```swift
override func viewDidLoad() {
  ...
  addNewTieFighter()
}
```

### [Step 6: Animate TIE fighter](https://github.com/cgrail/arWars/commit/01c16880540fced936e052ead752186f8c8f8d3c)

```swift
private func addNewTieFighter() {
  ...
  animateFighter(fighter)
}
```

### [Step 7: Remove 3D objects on contact](https://github.com/cgrail/arWars/commit/e8750c9769cf0c328fcc616b4172d5406cf3a9f4)

```swift
func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
  ...
  contact.nodeA.removeFromParentNode()
  contact.nodeB.removeFromParentNode()
}
```

### [Step 8: Play explosion animation and sound](https://github.com/cgrail/arWars/commit/759392f7bf116034f2c0dabeef6c3b8701787ca6)

```swift
func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
  ...
  assets.playSoundEffect(ofType: .explosion)
  createExplosion(contact.nodeA.position)
}
```

### [Step 9: Spawn new TIE Fighter](https://github.com/cgrail/arWars/commit/f19d9dc4f50fe150e36f557aedfa75a8631a4ccc)

```swift
func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
  ...
  DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.addNewTieFigher()
  }
}
```
