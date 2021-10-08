import SpriteKit
import UIKit
import SPCCore
import SPCScene
import SPCAccessibility

/// /*#-localizable-zone(gameLayoutCode1)*/A label that shows the results of an individual round/*#-end-localizable-zone*/.
public var resultLabel = DisplayLabel(position: Point(x: 0, y: 110))

/// /*#-localizable-zone(gameLayoutCode2)*/A label that shows the results of the game/*#-end-localizable-zone*/.
public var endGameLabel = EndGameLabel(position: Point(x: 0, y: 0))

/// /*#-localizable-zone(gameLayoutCode3)*/The visual layout of a Rock, Paper, Scissors Game/*#-end-localizable-zone*/.
public class GameLayout {
    
    static let resultLabelBackgroundLevel: CGFloat = 3.0
    static let actionItemLevel: CGFloat = 4.0
    static let playerGraphicLevel: CGFloat = 5.0
    static let overResultsDisplay: CGFloat = 8.0
    static let fightAnimationLevel: CGFloat = 6.5
    
    /// /*#-localizable-zone(gameLayoutCode4)*/Allows you to pick actions to play for each round/*#-end-localizable-zone*/.
    var actionPicker: ActionPicker
    
    var goButton: Button = Button(type: .rectangularRed, text: /*#-localizable-zone(gameLayoutGoButton)*/"GO"/*#-end-localizable-zone*/, name: "goButton")
    var startNewGameButton: Button = Button(type: .rectangularRed, text: /*#-localizable-zone(startNewGameButton)*/"New Game"/*#-end-localizable-zone*/, name: "startNewGameButton")
    
    var fadeInBackground: SKAction
    var fadeOutGroup: SKAction
    
    public var onGoHandler: () -> Void = { }
    public var onStartNewGameHandler: () -> Void = { }
    public var onVictoryHandler: (Player) -> Void = { player in }
    var animationDuration = 0.5
    
    public init() {
        let scaleToZeroSlow = SKAction.scale(to: 0, duration: animationDuration)
        let scaleToOneSlow = SKAction.scale(to: 1, duration: animationDuration)
        let fadeOut = SKAction.fadeOut(withDuration: animationDuration)
        let fadeTo = SKAction.fadeAlpha(to: 1.0, duration: animationDuration)
        fadeInBackground = SKAction.group([scaleToOneSlow, fadeTo])
        fadeOutGroup = SKAction.group([scaleToZeroSlow, fadeOut])
        
        goButton.scale = 1.25
        goButton.fontSize = 35
        goButton.textColor = .white
        goButton.makeAccessible(label: NSLocalizedString("Go button. Tap to play a round", comment: "VoiceOver string for the button to play a round of the game"))
        startNewGameButton.scale = 1.25
        startNewGameButton.zPosition = GameLayout.overResultsDisplay
        startNewGameButton.fontSize = 35
        startNewGameButton.textColor = .white
        resultLabel.background.zPosition = GameLayout.resultLabelBackgroundLevel
        startNewGameButton.makeAccessible(label: NSLocalizedString("New game button. Tap to start a new game", comment: "VoiceOver string for the new game button."))
        resultLabel.label.font  = .ChalkboardSE
        resultLabel.label.zPosition = GameLayout.actionItemLevel
        actionPicker = ActionPicker()
        
        onVictoryHandler = defaultVictoryHandler
    }
    
    /// /*#-localizable-zone(gameLayoutCode5)*/Updates the display for the start of a game/*#-end-localizable-zone*/.
    public func updateForStartOfGame(_ game: Game) {
        // /*#-localizable-zone(gameLayoutCode6)*/Lay out the opponents/*#-end-localizable-zone*/.
        setUpOpponentLayout(game: game)
        
        // /*#-localizable-zone(gameLayoutCode7)*/Set up the action picker/*#-end-localizable-zone*/.
        actionPicker.setUpActionPicker(for: game.challenger, with: Action.selectableActions)
        
        // /*#-localizable-zone(gameLayoutCode8)*/Set up the Go button/*#-end-localizable-zone*/.
        scene.place(goButton, at: Point(x: 0, y: -375))
        
        goButton.setOnPressHandler { _ in
            self.actionPicker.toggleSelectionArrows(on: false)
            // /*#-localizable-zone(gameLayoutCode9)*/Select the current action in the Action Picker/*#-end-localizable-zone*/.
            game.challenger.action = self.actionPicker.currentAction
            self.onGoHandler()
        }
        
        startNewGameButton.setOnPressHandler { _ in
            self.onStartNewGameHandler()
            self.updateForNewGame(game)
        }
    }
    
    /// /*#-localizable-zone(gameLayoutCode10)*/Updates the display for the end of the game/*#-end-localizable-zone*/.
    public func updateForEndOfGame(_ game: Game) {
        showEndGameLabel(true)
        
        // /*#-localizable-zone(gameLayoutCode11)*/Place the start game button on the scene/*#-end-localizable-zone*/.
        goButton.alpha = 0
        startNewGameButton.alpha = 0
        scene.place(startNewGameButton, at: Point(x: 0, y: -250))
        startNewGameButton.run(SKAction.sequence([SKAction.wait(forDuration: 2.5), SKAction.fadeIn(withDuration: 0.5)]))
        Accessibility.shiftFocus(to: startNewGameButton)
    }
    
    /// /*#-localizable-zone(gameLayoutCode12)*/Updates the display for a new game/*#-end-localizable-zone*/.
    public func updateForNewGame(_ game: Game) {
        prepareActionPicker()
        startNewGameButton.position.x = -750
    }
    
    /// /*#-localizable-zone(gameLayoutCode13)*/Updates the display after the players start a round/*#-end-localizable-zone*/.
    public func updateForStartOfRound() {
        goButton.alpha = 0
        resultLabel.text = ""
        showResultLabel(false)
    }
    
    /// /*#-localizable-zone(gameLayoutCode14)*/Updates the display for the end of a round/*#-end-localizable-zone*/.
    public func updateForEndOfRound() {
        showResultLabel(true)
    }
    
    /// /*#-localizable-zone(gameLayoutCode15)*/Updates the display for a new round/*#-end-localizable-zone*/.
    public func updateForNewRound() {
        prepareActionPicker()
    }
    
    /// /*#-localizable-zone(gameLayoutCode16)*/Shows the result of the round/*#-end-localizable-zone*/.
    public func showResult(message: String) {
        showResultLabel(true)
        resultLabel.text = message
        update(label: resultLabel, forMessage: message)
    }
    
    /// /*#-localizable-zone(gameLayoutCode17)*/Shows the final result of the game/*#-end-localizable-zone*/.
    public func showEndGameResult(message: String) {
        endGameLabel.text = message
    }
    
    /// /*#-localizable-zone(gameLayoutCode18)*/Shows the victory animation for a given player/*#-end-localizable-zone*/.
    public func showVictoryAnimation(player: Player) {
        onVictoryHandler(player)
    }
    
    /// /*#-localizable-zone(gameLayoutCode19)*/Shows the defeat animation for a given player/*#-end-localizable-zone*/.
    public func showDefeatAnimation(players: [Player]) {
        var avatarLayout: [Point] = [Point(x: 0, y: 0)]
        if players.count == 2 {
            avatarLayout = [Point(x: -150, y: 0), Point(x: 150, y: 0)]
        } else if players.count == 3 {
            avatarLayout = [Point(x: -200, y: 0), Point(x: 0, y: 0), Point(x: 200, y: 0)]
        }
        
        var count = 0
        for player in players {
            let graphic = player.graphic
            let scaleUp = SKAction.scale(by: 2, duration: 0.2)
            let scaleBack = SKAction.scale(by: 0.5, duration: 0.2)
            let pulse = SKAction.repeat(SKAction.sequence([scaleUp, scaleBack]), count: 3)
            
            graphic.scale(to: 3, duration: 1.0)
            graphic.moveAndFade(from: player.graphicPosition, to: avatarLayout[count], fade: .fadeIn, duration: 1.0) {
                graphic.run(pulse)
                
            }
            
            count += 1
        }
        
    }
    
    /// /*#-localizable-zone(gameLayoutCode20)*/Activates a default victory animation/*#-end-localizable-zone*/.
    public func defaultVictoryHandler(player: Player) {
        let graphic = player.graphic
        graphic.scale(to: 5, duration: 2)
        graphic.moveAndFade(from: player.graphicPosition, to: Point(x: 0, y: 0), fade: .fadeIn, duration: 2)
        scene.bubbles(duration: 4)
    }
    
    /// /*#-localizable-zone(gameLayoutCode21)*/Shows a series of ”who beats who“ with each action/*#-end-localizable-zone*/.
    public func showActionResults(for winners: [Player], completion: @escaping (() -> Void)) {
        var winner: Player = Player()
        let spinOut = SKAction.rotate(byAngle: 25.132, duration: 0.4)
        var opponentCount = 0
        var winnersCount = 0
        var movements: [SKAction] = []
        
        func onAnimationsComplete() {
            opponentCount = 0
            
            if winnersCount + 1 < winners.count {
                winnersCount += 1
                winnerSequence()
            } else {
                completion()
            }
        }
        
        func beatActionSequence() {
            let opponent = winner.beatPlayers[opponentCount]
            winner.action.graphic.zPosition = GameLayout.fightAnimationLevel
            let xDist = (opponent.actionPosition.x - winner.actionPosition.x) / 1.5
            let yDist = (opponent.actionPosition.y - winner.actionPosition.y) / 1.5
            
            let moveToward = SKAction.moveBy(x: CGFloat(xDist), y: CGFloat(yDist), duration: 0.3)
            let spin = SKAction.run({
                opponent.action.graphic.run(spinOut)
            })
            let moveBack = SKAction.move(to: winner.actionPosition.cgPoint, duration: 0.4)
            
            winner.action.graphic.run(SKAction.sequence([moveToward, spin, moveBack])) {
                if opponentCount + 1 < winner.beatPlayers.count {
                    opponentCount += 1
                    beatActionSequence()
                } else {
                    onAnimationsComplete()
                }
                winner.action.graphic.zPosition = GameLayout.actionItemLevel
            }
        }
        
        func winnerSequence() {
            winner = winners[winnersCount]
            beatActionSequence()
        }
        winnerSequence()
    }
    
    /// /*#-localizable-zone(gameLayoutCode22)*/Resets the layout/*#-end-localizable-zone*/.
    func reset() {
        actionPicker.toggleSelectionArrows(on: true)
        showEndGameLabel(false)
    }
    
    /// /*#-localizable-zone(gameLayoutCode23)*/Shows the Go button and the selection arrows for the ActionPicker. This happens at the start of a new round/*#-end-localizable-zone*/.
    func prepareActionPicker() {
        goButton.scale = 0.1
        goButton.alpha = 1
        goButton.run(SKAction.scale(to: 1.25, duration: 0.5))
        actionPicker.toggleSelectionArrows(on: true)
    }
    
    /// /*#-localizable-zone(gameLayoutCode24)*/Shows or hides the result label/*#-end-localizable-zone*/.
    func showResultLabel(_ bool: Bool) {
        if bool == true {
            resultLabel.background.run(SKAction.fadeAlpha(to: 1.0, duration: animationDuration))
            resultLabel.label.fadeIn(after: animationDuration + 0.5)
        } else {
            resultLabel.background.run(fadeOutGroup)
            resultLabel.label.fadeOut(after: animationDuration - 0.3)
        }
    }
    
    /// /*#-localizable-zone(gameLayoutCode25)*/Shows or hides the label for the end of the game/*#-end-localizable-zone*/.
    func showEndGameLabel(_ bool: Bool) {
        if bool == true {
            endGameLabel.background.run(fadeInBackground)
            endGameLabel.label.fadeIn(after: animationDuration + 0.5)
        } else {
            endGameLabel.background.run(fadeOutGroup)
            endGameLabel.label.fadeOut(after: animationDuration - 0.3)
        }
    }
    
    /// /*#-localizable-zone(gameLayoutCode26)*/Adds a trophy to the trophy case for the specified player. Trophies represent the number of wins that player has/*#-end-localizable-zone*/.
    func showTrophy(for player: Player, game: Game) {
        player.trophyCase.text = "\(player.winCount) \(game.roundPrize)"
        if player.type == .bot {
            Accessibility.announce(game.loseRoundText)
            resultLabel.text = game.loseRoundText
            update(label: resultLabel, forMessage: game.loseRoundText)
        } else {
            Accessibility.announce(NSLocalizedString("\(game.winRoundText). You now have \(player.winCount) trophies in your trophy case", comment: "VoiceOver announcement that the player has won or lost, and how many trophies (wins) the player has."))
            resultLabel.text = game.winRoundText
            update(label: resultLabel, forMessage: game.winRoundText)
        }
        player.trophyCase.scale = 2
        player.trophyCase.fadeIn(after: 1)
        player.trophyCase.run(SKAction.scale(to: 1, duration: 1.25))
    }

    private func update(label: DisplayLabel, forMessage message: String) {
        let font = UIFont(name: resultLabel.label.font.rawValue, size: CGFloat(resultLabel.label.fontSize))
        let fontAttributes = [NSAttributedString.Key.font: font]
        var size = (message as NSString).size(withAttributes: fontAttributes)
        if size.width < 250 {
            size.width = 250
        }
        label.background.run(SKAction.scaleX(to: CGFloat(size.width / 300), y: 1, duration: 0))
    }
    
    /// /*#-localizable-zone(gameLayoutCode27)*/Sets up the opponent display/*#-end-localizable-zone*/.
    private func setUpOpponentLayout(game: Game) {
        let defaultY = 325
        var scale = 0.85
        
        // /*#-localizable-zone(gameLayoutCode28)*/Limit to four opponents/*#-end-localizable-zone*/.
        let opponents = game.opponents.prefix(4)
        
        if opponents.count == 1 {
            opponents[0].layoutPosition = Point(x: 0, y: defaultY)
        } else if opponents.count == 2 {
            opponents[0].layoutPosition = Point(x: -200, y: defaultY)
            opponents[1].layoutPosition = Point(x: 200, y: defaultY)
        } else if opponents.count == 3 {
            opponents[0].layoutPosition = Point(x: -300, y: defaultY - 25)
            opponents[1].layoutPosition = Point(x: 0, y: defaultY + 15)
            opponents[2].layoutPosition = Point(x: 300, y: defaultY - 25)
            scale = 0.8
        } else {
            opponents[0].layoutPosition = Point(x: -375, y: defaultY - 50)
            opponents[1].layoutPosition = Point(x: -125, y: defaultY + 15)
            opponents[2].layoutPosition = Point(x: 125, y: defaultY + 15)
            opponents[3].layoutPosition = Point(x: 375, y: defaultY - 50)
            scale = 0.75
        }
        
        for opponent in opponents {
            let displayCircle = OpponentView()
            displayCircle.scale = scale
            let position = opponent.layoutPosition
            scene.place(displayCircle, at: position)
            
            opponent.graphicPosition = Point(x: position.x - (scale * 100), y: position.y + (scale * 120))
            opponent.graphic.fontSize = Int(scale * 50)
            scene.place(opponent.graphic, at: opponent.graphicPosition)
            
            opponent.trophyCase.text = "\(opponent.winCount) \(game.roundPrize)"
            scene.place(opponent.trophyCase, at: Point(x: opponent.layoutPosition.x, y: opponent.layoutPosition.y + Double(130 - (Double(game.opponents.count) * 5))))
            opponent.trophyCase.fontSize = 45 - (game.opponents.count * 3)
            
            opponent.actionPosition =  Point(x: opponent.layoutPosition.x, y: opponent.layoutPosition.y - (scale * 50))
            scene.place(opponent.action.graphic, at: opponent.actionPosition)
            opponent.action.graphic.fontSize = 150 - (opponents.count * 10)
        }
    }
}
