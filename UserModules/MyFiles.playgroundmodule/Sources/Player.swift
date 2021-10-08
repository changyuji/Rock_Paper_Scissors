import UIKit

enum PlayerType {
    case bot
    case human
}

/// /*#-localizable-zone(playerCode1)*/A participant in the Rock, Paper, Scissors game/*#-end-localizable-zone*/.
public class Player: Equatable, Hashable {

    let type: PlayerType

    var action: Action
    
    var graphic: Label
    
    var actionLabel = Label(text: "❓", color: .black, name: "actionLabel")
    
    var beatPlayers: [Player] = []
    
    var winCount: UInt = 0 {
        didSet {
            trophyCase.makeAccessible(label: getWinCountHint(for: type))
        }
    }
    
    var trophyCase: Label = Label(text: "", color: .black, name: "trophyCase")
    
    var layoutPosition: Point = Point(x: 0, y: -100)
    
    var actionPosition: Point = Point(x: 0, y: -125)
    
    var graphicPosition: Point = Point(x: 0, y: 750)
    
    var isRandom = false
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(emoji)
    }
    
    /// /*#-localizable-zone(playerCode2)*/The emoji used to represent the player's avatar/*#-end-localizable-zone*/.
    public var emoji: String {
        get { return graphic.text }
        set { graphic.text = newValue }
    }
    
    var name: String {
        get { return graphic.name ?? "" }
        set { graphic.name = newValue }
    }
    
    init(_ emoji: String = "", type: PlayerType = .human) {
        action = Action()
        self.type = type
        if type == .bot {
            isRandom = true
        }
        
        trophyCase.textColor = .white
        
        
        graphic = Label(text: emoji, color: .black, name: "playerGraphic")
        graphic.fontSize = 45
        graphic.zPosition = GameLayout.playerGraphicLevel
        trophyCase.makeAccessible(label: getWinCountHint(for: type))
    }
    
    public static func == (leftPlayer: Player, rightPlayer: Player) -> Bool {
        return leftPlayer.graphic == rightPlayer.graphic
    }
    
    private func getWinCountHint(for player: PlayerType) -> String {
        if type == .human {
            return NSLocalizedString("Your trophy case. Score is \(winCount)", comment: "VoiceOver hint for the number of wins the player currently has.")
        } else {
            return NSLocalizedString("Opponent trophy case. Score is \(winCount)", comment: "VoiceOver hint for the number of wins the opponent currently has.")
        }
    }
}
