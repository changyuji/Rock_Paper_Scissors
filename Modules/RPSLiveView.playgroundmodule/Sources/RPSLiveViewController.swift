//
//  BrickBreakerViewController.swift
//
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import SPCCore
import SPCLiveView
import SPCScene
import SPCAudio
import SPCAccessibility
import PlaygroundSupport
import UIKit

public class RPSViewController: LiveViewController {
    
    public init(scene: Scene) {
    super.init(nibName: nil, bundle: nil)
        
        
        LiveViewController.contentPresentation = .aspectFitMinimum
        
        let liveViewScene = scene
        
        lifeCycleDelegates = [audioController]
        contentView = liveViewScene.skView
        
    }

    required init?(coder: NSCoder) {
        fatalError("BrickBreakerViewController.init?(coder) not implemented.")
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        
//        let _ = scene // Required for some reason 🤷🏼‍♂️
//
//        setupSampleGame()
//
//        game.play()
    }
}

