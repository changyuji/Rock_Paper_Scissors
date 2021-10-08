import PlaygroundSupport
import MyFiles
import SPCAssessment
import Foundation



public class AssessmentManager {
    
    let learningTrails = LearningTrailsProxy()
    let fileFinder = UserModuleFileFinder()
    let mainFile = ContentsChecker(contents: PlaygroundPage.current.text)
    var myGameFile: ContentsChecker
    
    public init() {
        myGameFile = ContentsChecker(contents: fileFinder.getContents(ofFile: "MyGame", module: "MyFiles"))
    }
    
    public func runAssessmentPage01(game: Game) {
        if learningTrails.currentStep == "gameIsPlaying" {
            if game.isPlaying {
                learningTrails.setAssessment("gameIsPlaying", passed: true)
                learningTrails.sendMessageOnce("gameIsPlaying-success")
            } else {
                learningTrails.sendMessageOnce("gameIsPlaying-hint")
            }
        }
    }
    
    public func runAssessmentPage02(game: Game) {
        // Hint and success for adding an opponent.
        if learningTrails.currentStep == "addOpponent" {
            if game.opponents[0].emoji != "😈" {
                learningTrails.setAssessment("addOpponent", passed: true)
                learningTrails.sendMessageOnce("addOpponent-success")
            } else {
                learningTrails.sendMessageOnce("addOpponent-hint")
            }
        }


        // Hint and succes for changing the round prize.
        if learningTrails.currentStep == "roundPrize" {
            if myGameFile.variablesInFunctionDefinition(named: "setupGame").contains("game.roundPrize") && game.roundPrize != "🏆" {
                learningTrails.setAssessment("roundPrize", passed: true)
                learningTrails.sendMessageOnce("roundPrize-success")
            } else {
                if game.roundPrize != "🏆" {
                    learningTrails.sendMessageOnce("roundPrize-hint2")

                } else {
                    learningTrails.sendMessageOnce("roundPrize-hint1")
                }
            }
        }
    }
    
    public func runAssessmentPage03(game: Game) {
        let userActions = Action.allActions
        let defaultEmoji = ["👊", "✋", "✌️"]
        var actionContainBeatActions = true
        var addedHiddenAction = false
        var addedBeatsHiddenAction = false



        if learningTrails.currentStep == "addingActions1" {
            var defaultFound = false
            for action in userActions {
                // If the action contains any of the default action emoji, then fail.
                if defaultEmoji.contains(where: action.emoji.contains) {
                    defaultFound = true
                    break
                }
            }
            if defaultFound {
                learningTrails.sendMessageOnce("addingActions1-hint")
            } else {
                learningTrails.sendMessageOnce("addingActions1-success")
                learningTrails.setAssessment("addingActions1", passed: true)
                
            }
        }

        if learningTrails.currentStep == "addingActions2" {
            for action in userActions {
                if action.beatsActions.isEmpty {
                    actionContainBeatActions = false
                    break
                }
            }
            if actionContainBeatActions {
                learningTrails.sendMessageOnce("addingActions2-success")
                learningTrails.setAssessment("addingActions2", passed: true)
            } else {
                if learningTrails.hasSentMessage("addingActions2-hint") {
                    learningTrails.sendMessageOnce("addingActions2-hint2")
                }
                
                learningTrails.sendMessageOnce("addingActions2-hint")
                
            }
            
        }

        if learningTrails.currentStep == "hidden" {
            for action in userActions {
                if action.type == .hidden {
                    addedHiddenAction = true
                    
                    if !action.beatsActions.isEmpty {
                        addedBeatsHiddenAction = true
                    }
                }
            }
            
            if addedHiddenAction && addedBeatsHiddenAction {
                learningTrails.sendMessageOnce("hidden-success")
                learningTrails.setAssessment("hidden", passed: true)
            }
            
            if !addedHiddenAction {
                learningTrails.sendMessageOnce("hidden-hint")
            }
            
            if !addedBeatsHiddenAction {
                learningTrails.sendMessageOnce("hidden-hint2")
            }
        }
    }
    
    public func runAssessmentPage04(game: Game) {
        var roundsToWinChanged = false
        var roundPrizeChanged = false
        var winRoundTextChanged = false
        var loseRoundTextChanged = false
        var tieRoundTextChanged = false
        var challengerTextChanged = false


        if game.roundsToWin != 3 {
            roundsToWinChanged = true
            learningTrails.setTask("roundsToWinChanged", completed: true)
        }

        if game.roundPrize != "🏆" && game.roundPrize != "🍭" {
            roundPrizeChanged = true
            learningTrails.setTask("roundPrizeChanged", completed: true)
        }
        
        if "\"\(game.winRoundText)\"" != Bundle.main.localizedString(forKey: "gameYouWinString", value: "YOU WIN", table: "LocalizableCode") {
            winRoundTextChanged = true
            learningTrails.setTask("winRoundTextChanged", completed: true)
        }

        if "\"\(game.loseRoundText)\"" != Bundle.main.localizedString(forKey: "gameYouLoseString", value: "YOU LOSE", table: "LocalizableCode") {
            loseRoundTextChanged = true
            learningTrails.setTask("loseRoundTextChanged", completed: true)
        }

        if "\"\(game.tieRoundText)\"" != Bundle.main.localizedString(forKey: "gameYouTieString", value: "TIE", table: "LocalizableCode") {
            tieRoundTextChanged = true
            learningTrails.setTask("tieRoundTextChanged", completed: true)
        }

        if game.challenger.emoji != "😎" {
            challengerTextChanged = true
            learningTrails.setTask("challengerTextChanged", completed: true)
        }



        var step1ExperimentPassed = roundsToWinChanged || roundPrizeChanged || winRoundTextChanged || loseRoundTextChanged || tieRoundTextChanged || challengerTextChanged

        var allExperimentsPassed = roundsToWinChanged && roundPrizeChanged && winRoundTextChanged && loseRoundTextChanged && tieRoundTextChanged && challengerTextChanged

        if learningTrails.currentStep == "gameProperties" {
            if allExperimentsPassed {
                learningTrails.setAssessment("gameProperties", passed: true)
                learningTrails.sendMessageOnce("gameProperties-success2")
            } else if step1ExperimentPassed {
                learningTrails.sendMessageOnce("gameProperties-success1")
                learningTrails.setAssessment("gameProperties", passed: true)
            } else {
                learningTrails.sendMessageOnce("gameProperties-hint")
            }
        }
    }
    
    public func runAssessmentPage05(game: Game) {
        // Step 2
        var setANewVictoryHandler = false


        if learningTrails.currentStep == "winAnimation" {
            if game.onVictory != nil {
                setANewVictoryHandler = true
                learningTrails.setAssessment("winAnimation", passed: true)
                learningTrails.sendMessageOnce("winAnimation-success")
            } else {
                learningTrails.sendMessageOnce("winAnimation-hint")
            }
        }

        // Step 3
        var modifiedSceneAnimations = false
        var scaledPlayer = false
        var animatedPlayer = false

        if myGameFile.functionCallCount(forName: "scene.orbs") > 0 || myGameFile.functionCallCount(forName: "scene.confetti") > 0 {
            modifiedSceneAnimations = true
            learningTrails.setTask("modifiedSceneAnimations", completed: true)
        }

        if myGameFile.accessedVariables.contains("player.graphic.scale") {
            scaledPlayer = true
            learningTrails.setTask("scaledPlayer", completed: true)
        }

        if myGameFile.calledFunctions.contains("player.graphic.sparkle") || myGameFile.calledFunctions.contains("player.graphic.pulsate") {
            animatedPlayer = true
            learningTrails.setTask("animatedPlayer", completed: true)
        }

        var step3ExperimentPassed = modifiedSceneAnimations || scaledPlayer || animatedPlayer

        if learningTrails.currentStep == "sparkle" {
            if step3ExperimentPassed {
                learningTrails.setAssessment("sparkle", passed: true)
                learningTrails.sendMessageOnce("sparkle-success")
            } else {
                learningTrails.sendMessageOnce("sparkle-hint")
            }
        }
    }
    
    

    
}
