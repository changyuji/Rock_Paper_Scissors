import SpriteKit
import UIKit

/// /*#-localizable-zone(actionPicker1)*/A display for the player to choose one of the available actions. Toggles on and off after the player starts the round/*#-end-localizable-zone*/.
public class ActionPicker {
    
    var startPosition = Point(x: 0, y: -130)
    var graphicPosition = Point(x: 0, y: -105)
    var arrowDisplacement: Double = 215
    var leftArrow = Arrow(direction: .left)
    var rightArrow = Arrow(direction: .right)
    let displayCircle = PlayerView()
    
    /// /*#-localizable-zone(actionPicker2)*/The current action selected by the player/*#-end-localizable-zone*/.
    public var currentAction: Action = Action()
    
    init() {
    }
    
    /// /*#-localizable-zone(actionPicker3)*/Creates the Action Picker on the scene/*#-end-localizable-zone*/.
    public func setUpActionPicker(for player: Player, with actions: [Action]) {
        if let firstAction = actions.first {
            self.currentAction = firstAction
        }
        
        displayCircle.makeAccessible(label: currentActionVoiceOverHint())
        leftArrow.makeAccessible(label: NSLocalizedString("Previous. Button. Tap to select the previous action", comment: "VoiceOver hint for the previous action button"))
        rightArrow.makeAccessible(label: NSLocalizedString("Next. Button. Tap to select the next action", comment: "VoiceOver hint for the next action button"))
        
        leftArrow.pressHandler = {
            self.nextAction(direction: .left, within: actions)
        }
        
        rightArrow.pressHandler = {
            self.nextAction(direction: .right, within: actions)
        }
        
        game.challenger.actionPosition = graphicPosition
        
        scene.place(displayCircle, at: startPosition)
        scene.place(leftArrow, at: Point(x: -arrowDisplacement, y: graphicPosition.y))
        scene.place(rightArrow, at: Point(x: arrowDisplacement, y: graphicPosition.y))
        scene.place(currentAction.graphic, at: Point(x: 0, y: graphicPosition.y))
        player.graphicPosition = Point(x: startPosition.x - 100, y: startPosition.y - 120)
        player.graphic.fontSize = 60
        scene.place(player.graphic, at: player.graphicPosition)
        
        player.trophyCase.text = "\(player.winCount) \(game.roundPrize)"
        player.trophyCase.fontSize = 50
        scene.place(player.trophyCase, at: Point(x: player.layoutPosition.x, y: player.layoutPosition.y - 180))
        
        place(actions: actions)
        toggleSelectionArrows(on: true)
    }
    
    /// /*#-localizable-zone(actionPicker4)*/Toggles on and off the selection arrows for choosing an action/*#-end-localizable-zone*/.
    public func toggleSelectionArrows(on: Bool) {
        if !on {
            leftArrow.alpha = 0.0
            rightArrow.alpha = 0.0
            leftArrow.position.x = 500
            rightArrow.position.x = 500
        } else {
            leftArrow.scale = 0.1
            rightArrow.scale = 0.1
            leftArrow.alpha = 1.0
            rightArrow.alpha = 1.0
            leftArrow.position.x = -arrowDisplacement.cgFloat
            rightArrow.position.x = arrowDisplacement.cgFloat
            leftArrow.run(SKAction.scale(to: 2, duration: 0.5))
            rightArrow.run(SKAction.scale(to: 2, duration: 0.5))
        }
        
    }
    
    /// /*#-localizable-zone(actionPicker5)*/Places all of the actions on the scene, making all but one invisible/*#-end-localizable-zone*/.
    func place(actions: [Action]) {
        for action in actions {
            scene.place(action.graphic, at: graphicPosition)
            if action != currentAction {
                action.graphic.alpha = 0
            }
        }
    }
    
    /// /*#-localizable-zone(actionPicker6)*/Moves to the next available action in either direction/*#-end-localizable-zone*/.
    func nextAction(direction: Direction, within actions: [Action]) {
        guard let currentIndex = actions.firstIndex(of: currentAction) else { return }
        var nextIndex = 0
        let animationDuration = 0.1
        let leftPosition = Point(x: startPosition.x - 100, y: graphicPosition.y)
        let rightPosition = Point(x: startPosition.x + 100, y: graphicPosition.y)
        var toPosition: Point
        var fromPosition: Point
        switch direction {
        case .left:
            toPosition = leftPosition
            fromPosition = rightPosition
            nextIndex = currentIndex - 1
            if nextIndex < 0 {
                nextIndex = actions.count - 1
            }
        case .right:
            toPosition = rightPosition
            fromPosition = leftPosition
            nextIndex = currentIndex + 1
            if nextIndex == actions.count {
                nextIndex = 0
            }
        }
        displayCircle.makeAccessible(label: currentActionVoiceOverHint())
        currentAction.graphic.moveAndFade(from: graphicPosition, to: toPosition, fade: .fadeOut, duration: animationDuration)
        currentAction = actions[nextIndex]
        currentAction.graphic.moveAndFade(from: fromPosition, to: graphicPosition, fade: .fadeIn, duration: animationDuration)
    }
    
    private func currentActionVoiceOverHint() -> String {
        return NSLocalizedString("Action Picker. The current action is \(currentAction.emoji)", comment: "VoiceOver hint for the current action (rock, paper, scissors, etc.).")
    }
}

public extension Label {
    enum FadeDirection {
        case fadeOut
        case fadeIn
    }
    
    /// /*#-localizable-zone(actionPicker7)*/The animation for moving the next action to the center of the action picker/*#-end-localizable-zone*/.
    func moveAndFade(from point: Point, to newPosition: Point, fade: FadeDirection, duration: Double, completion: (() -> Void)? = nil) {
        location = point
        let move = SKAction.move(to: CGPoint(x: newPosition.x, y: newPosition.y), duration: duration)
        var fadeAction: SKAction
        switch fade {
            case .fadeOut:
                alpha = 1.0
                fadeAction = SKAction.fadeOut(withDuration: duration)
            case .fadeIn:
                alpha = 0.0
                fadeAction = SKAction.fadeIn(withDuration: duration)
        }
        let group = SKAction.group([move, fadeAction])
        run(group) {
            if let handler = completion {
                handler()
            }
        }
    }
}

enum Direction {
    case left
    case right
}
