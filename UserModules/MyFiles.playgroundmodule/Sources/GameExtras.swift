import SpriteKit
import UIKit

public let scene = Scene()

public extension Scene {
    /// /*#-localizable-zone(sharedCode1)*/Rains confetti from the sky/*#-end-localizable-zone*/.
    func confetti(duration: Double, color: Color = Color.clear) {
        addParticleEmitter(name: "Confetti", duration: duration, color: color)
    }
    
    /// /*#-localizable-zone(sharedCode2)*/Displays colored orbs that fill the scene/*#-end-localizable-zone*/.
    func orbs(duration: Double, color: Color = Color.clear) {
        addParticleEmitter(name: "Orbs", duration: duration, color: color)
    }
    
    /// /*#-localizable-zone(sharedCode3)*/Generates bubbles that percolate from the bottom of the scene/*#-end-localizable-zone*/.
    func bubbles(duration: Double, color: Color = Color.clear) {
        addParticleEmitter(name: "Bubbles", duration: duration, color: color)
    }
    
    /// /*#-localizable-zone(sharedCode4)*/Generates rain that falls on the scene/*#-end-localizable-zone*/.
    func rain(duration: Double, color: Color = Color.clear) {
        addParticleEmitter(name: "Rain", duration: duration, color: color)
    }
    
    /// /*#-localizable-zone(sharedCode5)*/Moves clouds across the scene/*#-end-localizable-zone*/.
    func clouds(duration: Double, color: Color = Color.clear) {
        addParticleEmitter(name: "Clouds", duration: duration, color: color)
    }
}

public extension Graphic {
    /// /*#-localizable-zone(sharedCode6)*/Moves the graphic up and down to simulate a bouncing effect/*#-end-localizable-zone*/.
    func bounce() {
        var distance: CGFloat = 100
        var actions: [SKAction] = []
        
        for _ in 1...9 {
            distance -= 8
            let up = SKAction.moveBy(x: 0, y: distance, duration: TimeInterval(0.002 * distance))
            up.timingMode = .easeOut
            let down = SKAction.moveBy(x: 0, y: -distance, duration: TimeInterval(0.0020 * distance))
            down.timingMode = .easeIn
            actions.append(up)
            actions.append(down)
        }
        
        let jumpSequence = SKAction.sequence(actions)
        self.run(jumpSequence)
    }
    
}

public extension Label {
    /// /*#-localizable-zone(sharedCode7)*/Tiny orbs of light dance around the graphic./*#-end-localizable-zone*/
    func sparkle(duration: Double, color: Color) {
        addParticleEmitter(name: "Sparkles", duration: duration, color: color)
    }
}
