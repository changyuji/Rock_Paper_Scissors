import UIKit

/// /*#-localizable-zone(actionCode1)*/Supported action types/*#-end-localizable-zone*/.
public enum ActionType {
    case standard
    case random
    case hidden
}

/// /*#-localizable-zone(actionCode2)*/A class that represents an action for the game. You can set an emoji to customize your action/*#-end-localizable-zone*/.
public class Action: Equatable {

    public var type: ActionType
    
    public static var allActions: [Action] = []
    public static var selectableActions: [Action] = []

    public var beatsActions = [Action]()
    
    public var graphic: Label = Label(text: "❓", color: .black)
    
    public var emoji: String {
        get { return graphic.text }
        set { graphic.text = newValue }
    }
    
    public init() {
        type = .standard
    }
    
    init(_ emoji: String, type: ActionType = .standard) {
        self.type = type
        graphic = Label(text: emoji, color: .black, name: "actionGraphic")
        graphic.fontSize = 150
        graphic.zPosition = GameLayout.actionItemLevel
        Action.allActions += [self]
        if type != .hidden {
            Action.selectableActions += [self]
        }
    }

    /// /*#-localizable-zone(actionCode3)*/Add an action that the current action can beat/*#-end-localizable-zone*/.
    public func beats(_ action: Action) {
        beats([action])
    }

    
    /// /*#-localizable-zone(actionCode4)*/Add an array of actions that the current action can beat/*#-end-localizable-zone*/.
    public func beats(_ actions: [Action]) {
        beatsActions += actions
    }
    
    
    /// /*#-localizable-zone(actionCode5)*/Check to see if the current action beats the passed in action/*#-end-localizable-zone*/.
    func isWinner(comparedTo action: Action) -> Bool {
        return beatsActions.contains(action)
    }
    
    /// /*#-localizable-zone(actionCode6)*/Compares the current action to another action to return either a win, lose, or tie/*#-end-localizable-zone*/.
    func compare(to action: Action) -> GameResult {
        if isWinner(comparedTo: action) {
            return .win
        }
        else if action.isWinner(comparedTo: self) {
            return .lose
        }
        
        return .tie
    }
    
    public static func == (leftAction: Action, rightAction: Action) -> Bool {
        return leftAction.emoji == rightAction.emoji
    }
}

