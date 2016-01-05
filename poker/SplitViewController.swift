//
//  SplitViewController.swift
//  poker
//
//  Created by Paul Sudol on 1/5/16.
//  Copyright © 2016 Paul Sudol. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {
 
    var game = Game()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 1...10 {
            game.newRound()
           
            game.currentRound!.flop()
            game.currentRound!.turn()
            game.currentRound!.river()
            
            game.saveRound()
        }

        var roundSelectorController = childViewControllers[0]
        var handViewController = childViewControllers[1]
        

    }
}
