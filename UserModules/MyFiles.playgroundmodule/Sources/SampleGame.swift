import UIKit

/// /*#-localizable-zone(sampleGame)*/This is a sample game of Rock, Paper, Scissors. Feel free to make it your own!/*#-end-localizable-zone*/
public func setupSampleGame() {
    game.roundsToWin = 3
    game.challenger.emoji = "🐼"
    
    game.addOpponent("🤖")
    game.addOpponent("🧑‍🎤")
    
    game.roundPrize = "🏅"
    game.winRoundText = "/*#-localizable-zone(sampleGameWinText)*/🐼 WINS/*#-end-localizable-zone*/"
    game.loseRoundText = "😭"
    game.tieRoundText = "🤷"
    
    let rock = Action("🗿")
    let paper = Action("📜")
    let scissors = Action("✂️")
    
    let fire = Action("🔥")
    let water = Action("🌊")
    let wind = Action("🌬")
    
    let snake = Action("🐍")
    let eagle = Action("🦅")
    let wolf = Action("🐺")
    
    let genie = Action("🧞", type: .hidden)
    for action in Action.allActions {
        genie.beats(action)
    }
    
    rock.beats([fire, scissors, snake])
    scissors.beats([wind, paper, wolf])
    paper.beats([rock, water, eagle])
    
    fire.beats([wind, paper, wolf])
    water.beats([fire, scissors, snake])
    wind.beats([water, rock, eagle])
    
    wolf.beats([eagle, paper, water])
    snake.beats([wolf, rock, wind])
    eagle.beats([snake, scissors, fire])
    
    game.onVictory = { player in
        player.graphic.scale(to: 3, duration: 2)
        player.graphic.moveAndFade(from: player.graphic.location, to: Point(x: 0, y: 0), fade: .fadeIn, duration: 2)
        scene.bubbles(duration: 7)
    }
}
