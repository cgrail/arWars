# ArWars

A small example project I've live coded at the Google Developer Group conference DevFest 2017 in Karlsruhe Germany. 

http://www.devfestka.de/programm

It is based on ARKit and demonstrates general 3D development basics, SceneKit, loading 3D Models, the PhysicsEngine and the AVAudioPlayer.

## Step by Step Guide

Checkout commit ["Initial version"](https://github.com/cgrail/arWars/commit/d1189323fed15922fa9789b91aca61f35e116a89) 

### Step 1: Create laser

```swift
 override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      let laser = createLaser()
  }
```

### Step 2: Add physics and animate laser

```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  ...
  addPhysics(laser)
  animateLaser(laser)
}
```

### Step 3: Play laser sound

```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  ...
  assets.playSoundEffect(ofType: .laser)
}
```

### Step 4: Make laser disappear after 1 second

```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  ...
  DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      laser.removeFromParentNode()
  }
}
```

### Step 5: Add new TIE Fighter

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    sceneView.scene = SCNScene()
    sceneView.scene.physicsWorld.contactDelegate = self
    sceneView.autoenablesDefaultLighting = true

    addNewTieFigher()
}
```

### Step 6: Animate TIE fighter

```swift
private func addNewTieFigher() {
  ...
  animateFighter(fighter)
}
```

### Step 7: Implement physics contact

```swift
func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    guard contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.fighter.rawValue
        || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.fighter.rawValue else { return }

    contact.nodeA.removeFromParentNode()
    contact.nodeB.removeFromParentNode()
}
```

### Step 8: Play explosion animation and sound

```swift
func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
  ...
  assets.playSoundEffect(ofType: .explosion)
  createExplosion(contact.nodeA.position)
}
```

### Step 9: Spawn new TIE Fighter

```swift
func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
  ...
  DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.addNewTieFigher()
  }
}
```
