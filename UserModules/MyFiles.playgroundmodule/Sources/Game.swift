import SpriteKit
import UIKit
import SPCCore
import SPCScene
import SPCAccessibility

/// /*#-localizable-zone(gameCode1)*/Game comparison possible outcomes/*#-end-localizable-zone*/.
public enum GameResult {
    case tie
    case win
    case lose
}

/// /*#-localizable-zone(gameCode2)*/The Rock, Paper, Scissors game/*#-end-localizable-zone*/.
public class Game {
    /// /*#-localizable-zone(gameCode3)*/The number of rounds a player must win before they can win the whole game/*#-end-localizable-zone*/.
    public var roundsToWin: UInt = 3
    
    /// /*#-localizable-zone(gameCode4)*/The emoji to show when a player wins a game/*#-end-localizable-zone*/.
    public var roundPrize = "🏆"
    
    /// /*#-localizable-zone(gameCode5)*/All the players in the game, including the challenger and all opponents/*#-end-localizable-zone*/.
    var players = [Player]()
    
    /// /*#-localizable-zone(gameCode6)*/All non-human players in the game/*#-end-localizable-zone*/.
    public var opponents = [Player]()
    
    /// /*#-localizable-zone(gameCode7)*/Determines whether the game can be played or not/*#-end-localizable-zone*/.
    public var canPlay = true
    
    /// /*#-localizable-zone(gameCode8)*/The result of an individual round/*#-end-localizable-zone*/.
    var roundResult = GameResult.tie
    
    /// /*#-localizable-zone(gameCode9)*/The human player of the game/*#-end-localizable-zone*/.
    public var challenger: Player = Player("😎", type: .human)
    
    /// /*#-localizable-zone(gameCode10)*/Text shown when you win a round/*#-end-localizable-zone*/.
    public var winRoundText: String = /*#-localizable-zone(gameYouWinString)*/"YOU WIN"/*#-end-localizable-zone*/
    
    /// /*#-localizable-zone(gameCode11)*/Text shown when you lose a round/*#-end-localizable-zone*/.
    public var loseRoundText: String = /*#-localizable-zone(gameYouLoseString)*/"YOU LOSE"/*#-end-localizable-zone*/
    
    /// /*#-localizable-zone(gameCode12)*/Text shown when you tie a round/*#-end-localizable-zone*/.
    public var tieRoundText: String = /*#-localizable-zone(gameYouTieString)*/"TIE"/*#-end-localizable-zone*/
    
    /// /*#-localizable-zone(gameCode13)*/Text shown when you win the game/*#-end-localizable-zone*/.
    public var victoryText: String = /*#-localizable-zone(gameVictoryString)*/"VICTORY"/*#-end-localizable-zone*/
    
    /// /*#-localizable-zone(gameCode14)*/Text shown when you lose the game/*#-end-localizable-zone*/.
    public var defeatText: String = /*#-localizable-zone(gameDefeatString)*/"DEFEAT"/*#-end-localizable-zone*/
    
    /// /*#-localizable-zone(gameCode15)*/Runs when the human player wins the game/*#-end-localizable-zone*/.
    public var onVictory: ((Player) -> Void)? = nil {
        didSet {
            gameLayout.onVictoryHandler = onVictory ?? gameLayout.defaultVictoryHandler
        }
    }
    
    var gameLayout = GameLayout()
    
    var soundTimer: Timer = Timer()
    
    public var isPlaying = false
    
    public init() { }
    
    /// /*#-localizable-zone(gameCode16)*/Adds a new opponent to the game/*#-end-localizable-zone*/.
    public func addOpponent(_ emoji: String) {
        guard opponents.count < 4 else { return }
        let opponent = Player(emoji, type: .bot)
        
        players.append(opponent)
        opponents += [opponent]
        opponent.name = opponent.emoji + "\(opponents.count)"
    }
    
    /// /*#-localizable-zone(gameCode17)*/Starts the Rock, Paper, Scissors game/*#-end-localizable-zone*/.
    public func play() {
        isPlaying = true
        
        // /*#-localizable-zone(gameCode18)*/If not enough actions have been provided, add some default actions/*#-end-localizable-zone*/.
        if Action.selectableActions.count < 2 {
            createDefaultActions()
        }
        // /*#-localizable-zone(gameCode19)*/If the player doesn’t select an opponent, add a default opponent/*#-end-localizable-zone*/.
        if opponents.isEmpty {
            addOpponent("😈")
        }
        
        players.append(challenger)
        
        gameLayout.onGoHandler = {
            self.startRound()
        }
        
        gameLayout.onStartNewGameHandler = {
            self.resetGame()
        }
        
        gameLayout.updateForStartOfGame(self)
    }
    
    /// /*#-localizable-zone(gameCode20)*/Starts a new round after the player selects an action/*#-end-localizable-zone*/.
    public func startRound() {
        game.players.forEach { $0.beatPlayers = [] }
        randomlySelectOpponentActions(from: Action.allActions)
        
        gameLayout.updateForStartOfRound()
        
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false, block: { timer in
            self.endRound()
            scene.run(SKAction.wait(forDuration: 1.0)) {
                if self.canPlay {
                    self.gameLayout.updateForNewRound()
                }
            }
        })
    }
    
    /// /*#-localizable-zone(gameCode21)*/Ends the round by calculating the winners and checking if anyone has won the game/*#-end-localizable-zone*/.
    public func endRound() {
        let winners = calculateWinners()
        
        // /*#-localizable-zone(gameCode22)*/If it’s a tie, award nothing/*#-end-localizable-zone*/.
        if winners.count == 0 {
            Accessibility.announce(tieRoundText)
            gameLayout.showResult(message: tieRoundText)
            return
        }
        
        
        gameLayout.showActionResults(for: winners) { [self] in
            // /*#-localizable-zone(gameCode23)*/Determine if anyone wins the game/*#-end-localizable-zone*/.
            var gameWinners: [Player] = []
            for winner in winners {
                winner.winCount += 1
                
                gameLayout.showTrophy(for: winner, game: self)
                if winner.winCount == roundsToWin {
                    canPlay = false
                    gameWinners.append(winner)
                }
            }
            
            if gameWinners.contains(challenger) {
                endGame(player: challenger)
            } else if !gameWinners.isEmpty {
                endGameInDefeat(winners: gameWinners)
            } else {
                gameLayout.updateForEndOfRound()
            }
        }
    }
    
    /// /*#-localizable-zone(gameCode24)*/Ends the game when the human player wins/*#-end-localizable-zone*/.
    public func endGame(player: Player) {
        canPlay = false
        gameLayout.updateForEndOfGame(self)
        player.graphic.zPosition = GameLayout.overResultsDisplay
        // /*#-localizable-zone(gameCode25)*/Show the end game victory animation/*#-end-localizable-zone*/.
        gameLayout.showVictoryAnimation(player: player)
        Accessibility.announce(victoryText)
        gameLayout.showEndGameResult(message: victoryText)
    }
    
    /// /*#-localizable-zone(gameCode26)*/Ends the game when one or more computer players win/*#-end-localizable-zone*/.
    public func endGameInDefeat(winners: [Player]) {
        canPlay = false
        gameLayout.updateForEndOfGame(self)
        winners.map { $0.graphic.zPosition = GameLayout.overResultsDisplay }
        gameLayout.showDefeatAnimation(players: winners)
        Accessibility.announce(defeatText)
        gameLayout.showEndGameResult(message: defeatText)
    }
    
    /// /*#-localizable-zone(gameCode27)*/Resets the game/*#-end-localizable-zone*/.
    func resetGame() {
        canPlay = true
        players.forEach( {
            $0.winCount = 0
         $0.trophyCase.text = "\($0.winCount) \(roundPrize)"
         $0.graphic.scale = 1
         $0.graphic.zPosition = GameLayout.playerGraphicLevel
         $0.graphic.location = $0.graphicPosition
        })
        gameLayout.reset()
    }
    
    /// /*#-localizable-zone(gameCode28)*/Creates a set of default actions if none were specified/*#-end-localizable-zone*/.
    func createDefaultActions() {
        let rock = Action("👊")
        let paper = Action("✋")
        let scissors = Action("✌️")
        rock.beats(scissors)
        paper.beats(rock)
        scissors.beats(paper)
    }
    
    /// /*#-localizable-zone(gameCode29)*/Calculates the winners of the current round/*#-end-localizable-zone*/.
    func calculateWinners() -> [Player] {
        var winners = [Player]()
        for currentPlayer in players {
            var beatenPlayers: Set<Player> = []
            var isCurrentPlayerWinner = false
            for otherPlayer in players {
                if currentPlayer != otherPlayer {
                    let result = currentPlayer.action.compare(to: otherPlayer.action)
                    
                    if result == .win {
                        isCurrentPlayerWinner = true
                        beatenPlayers.insert(otherPlayer)
                    }
                    else if result == .lose {
                        isCurrentPlayerWinner = false
                        break
                    }
                }
            }
            
            currentPlayer.beatPlayers = Array(beatenPlayers)
            
            if isCurrentPlayerWinner {
                winners.append(currentPlayer)
            }
        }
        
        return winners
    }
    
    /// /*#-localizable-zone(gameCode30)*/Randomly selects an action for the opponent/*#-end-localizable-zone*/.
    func randomlySelectOpponentActions(from actions: [Action]) {
        // /*#-localizable-zone(gameCode31)*/Create an array of randomly-shuffled actions for each opponent/*#-end-localizable-zone*/.
        var shuffledActions = [[Action]]()
        opponents.forEach({ _ in
            shuffledActions.append(actions.shuffled())
        })
        
        // /*#-localizable-zone(gameCode32)*/Points to the next set of actions in shuffledActions/*#-end-localizable-zone*/.
        var actionIndex = 0

        let randomActionTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { timer in
            for (index, opponent) in self.opponents.enumerated() {
                // /*#-localizable-zone(gameCode33)*/Pick the next action from the shuffled array for the opponent/*#-end-localizable-zone*/.
                let tempAction = shuffledActions[index][actionIndex]
                opponent.action.graphic.text = tempAction.emoji
                opponent.action.beatsActions = tempAction.beatsActions
                opponent.action.type = tempAction.type
            }
            actionIndex = (actionIndex + 1) % actions.count
        })
        
        // /*#-localizable-zone(gameCode34)*/Let the above random action timer run for two seconds/*#-end-localizable-zone*/.
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            randomActionTimer.invalidate()
            self.soundTimer.invalidate()
        }
    }
}
