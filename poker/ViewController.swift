//
//  ViewController.swift
//  poker
//
//  Created by Paul Sudol on 12/31/15.
//  Copyright © 2015 Paul Sudol. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource{

    // MARK: Properties
    @IBOutlet weak var seatOneCardOne: NSImageView!
    @IBOutlet weak var seatOneCardTwo: NSImageView!
    
    @IBOutlet weak var seatTwoCardOne: NSImageView!
    @IBOutlet weak var seatTwoCardTwo: NSImageView!
    
    @IBOutlet weak var seatThreeCardOne: NSImageView!
    @IBOutlet weak var seatThreeCardTwo: NSImageView!
    
    @IBOutlet weak var seatFourCardOne: NSImageView!
    @IBOutlet weak var seatFourCardTwo: NSImageView!
    
    @IBOutlet weak var seatFiveCardOne: NSImageView!
    @IBOutlet weak var seatFiveCardTwo: NSImageView!
    
    @IBOutlet weak var seatSixCardOne: NSImageView!
    @IBOutlet weak var seatSixCardTwo: NSImageView!
    
    @IBOutlet weak var seatSevenCardOne: NSImageView!
    @IBOutlet weak var seatSevenCardTwo: NSImageView!
    
    @IBOutlet weak var seatEightCardOne: NSImageView!
    @IBOutlet weak var seatEightCardTwo: NSImageView!
    
    @IBOutlet weak var seatNineCardOne: NSImageView!
    @IBOutlet weak var seatNineCardTwo: NSImageView!
    
    @IBOutlet weak var seatTenCardOne: NSImageView!
    @IBOutlet weak var seatTenCardTwo: NSImageView!
    
    @IBOutlet weak var boardOne: NSImageView!
    @IBOutlet weak var boardTwo: NSImageView!
    @IBOutlet weak var boardThree: NSImageView!
    @IBOutlet weak var boardFour: NSImageView!
    @IBOutlet weak var boardFive: NSImageView!
    
    @IBOutlet var seatOneBox: NSBox!
    @IBOutlet var seatTwoBox: NSBox!
    @IBOutlet var seatThreeBox: NSBox!
    @IBOutlet var seatFourBox: NSBox!
    @IBOutlet var seatFiveBox: NSBox!
    @IBOutlet var seatSixBox: NSBox!
    @IBOutlet var seatSevenBox: NSBox!
    @IBOutlet var seatEightBox: NSBox!
    @IBOutlet var seatNineBox: NSBox!
    @IBOutlet var seatTenBox: NSBox!
    
    var game = Game()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 1...100 {
            game.newRound()
            
            game.currentRound!.flop()
            game.currentRound!.turn()
            game.currentRound!.river()

            game.saveRound()
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
            print("representedObject.didSet")
        }
    }
    
    func showRound(roundId: Int) {
        if roundId < 0 {
            return
        }
        seatEightBox.borderType = NSBorderType.LineBorder
        seatEightBox.borderColor = NSColor.alternateSelectedControlColor()
        seatEightBox.borderWidth = 4
        
        /*
        An array to hold all the card images according to seats. We are
        assuming that player 1 will always sit in seat 1.
        */
        var seats = [
            [seatOneCardOne,seatOneCardTwo],
            [seatTwoCardOne,seatTwoCardTwo],
            [seatThreeCardOne,seatThreeCardTwo],
            [seatFourCardOne,seatFourCardTwo],
            [seatFiveCardOne,seatFiveCardTwo],
            [seatSixCardOne,seatSixCardTwo],
            [seatSevenCardOne,seatSevenCardTwo],
            [seatEightCardOne,seatEightCardTwo],
            [seatNineCardOne,seatNineCardTwo],
            [seatTenCardOne,seatTenCardTwo]
        ]

        var board = [boardOne, boardTwo, boardThree, boardFour, boardFive]
        
        var players = game.rounds[roundId].players

        for x in 0..<seats.count {
            seats[x][0]?.image = players[x].hand.cards[0].getImage()

            seats[x][1]?.image = players[x].hand.cards[1].getImage()
        }
        
        for x in 0..<board.count {
            board[x]?.image = game.rounds[roundId].board[x].getImage()
        }
    }
    
    //MARK: NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return game.rounds.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        
        if tableColumn!.identifier == "roundId" {
            let roundId = row
            cellView.textField!.stringValue = "Hand \(game.rounds[roundId].id)"
            
            return cellView
        }
        
        return cellView
    }
    
    //MARK: NSTableViewDelegate
    func tableViewSelectionDidChange(notification: NSNotification) {
        showRound((notification.object?.selectedRow)!)
    }
    
}

