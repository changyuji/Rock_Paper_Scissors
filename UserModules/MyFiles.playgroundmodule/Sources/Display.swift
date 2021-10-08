import UIKit

/// /*#-localizable-zone(displayCode1)*/The view showing the computer player's avatar and win count/*#-end-localizable-zone*/.
public class OpponentView: Graphic {
    public init() {
        super.init(image: #imageLiteral(resourceName: "OpponentPlayerView_2x.png"), name: "OpponentView")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// /*#-localizable-zone(displayCode2)*/The view showing the human player's avatar and win count/*#-end-localizable-zone*/.
public class PlayerView: Graphic {
    public init() {
        super.init(image: #imageLiteral(resourceName: "YourPlayerView_2x.png"), name: "PlayerView")
        self.scale = 0.75
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public enum ArrowDirection {
    case left
    case right
}

/// /*#-localizable-zone(displayCode3)*/An arrow used to moved between actions/*#-end-localizable-zone*/.
public class Arrow: Graphic {
    public var pressHandler: (() -> Void) = {}
    
    public init(direction: ArrowDirection) {
        super.init(graphicType: .graphic, name: "playerDisplay")
        switch direction {
        case .left:
            self.image = #imageLiteral(resourceName: "button1_left_up@2x.png")
        case .right:
            self.image = #imageLiteral(resourceName: "button1_right_up@2x.png")
            
        }
        self.scale = 2
        
        self.setOnTouchHandler { _ in
            self.pressHandler()
            
            switch direction {
            case .left:
                self.image = #imageLiteral(resourceName: "button1_left_down@2x.png")
            case .right:
                self.image = #imageLiteral(resourceName: "button1_right_down@2x.png")
            }
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (_) in
                switch direction {
                case .left:
                    self.image = #imageLiteral(resourceName: "button1_left_up@2x.png")
                case .right:
                    self.image = #imageLiteral(resourceName: "button1_right_up@2x.png")
                    
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// /*#-localizable-zone(displayCode4)*/A label with a background to display the round results/*#-end-localizable-zone*/.
public class DisplayLabel {
    let label = Label(text: "", color: .white, font: .ChalkboardSE, size: 60, name: "display")
    let background = Graphic.rectangle(width: 400, height: 100, cornerRadius: 10, color: #colorLiteral(red: 0.05418055505, green: 0.5529819131, blue: 0.8273463845, alpha: 1.0))
    
    var text: String {
        get { return label.text }
        set { label.text = newValue }
    }
    
    public init(position: Point) {
        background.alpha = 0
        background.scale = 0
        label.alpha = 0
        scene.place(label, at: position)
        scene.place(background, at: position)
    }
}

/// /*#-localizable-zone(displayCode5)*/A label with a background to show the end of game results/*#-end-localizable-zone*/.
public class EndGameLabel {
    let background = Graphic(image: #imageLiteral(resourceName: "WinLoseScreenBkgd@2x.png"), name: "endGameDisplay")
    let label = Label(text: "", color: .white, font: .ChalkboardSE, size: 80, name: "endGameDisplay")
    
    var text: String {
        get { return label.text }
        set { label.text = newValue }
    }
    
    public init(position: Point) {
        background.zPosition = 7
        label.zPosition = 8
        background.alpha = 0
        background.scale = 0
        label.alpha = 0
        scene.place(label, at: Point(x: position.x, y: position.y + 250))
        scene.place(background, at: position)
    }
}
