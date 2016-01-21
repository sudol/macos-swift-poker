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
    
    @IBOutlet var summaryBox: NSTextView!
    
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
        }
    }
    
    func showRound(roundId: Int) {
        if roundId < 0 {
            return
        }
        
        /*
        An array to hold all the card images according to seats. We are
        assuming that player 1 will always sit in seat 1.
        */
        var seats = [
            [seatOneBox,seatOneCardOne,seatOneCardTwo],
            [seatTwoBox,seatTwoCardOne,seatTwoCardTwo],
            [seatThreeBox,seatThreeCardOne,seatThreeCardTwo],
            [seatFourBox,seatFourCardOne,seatFourCardTwo],
            [seatFiveBox,seatFiveCardOne,seatFiveCardTwo],
            [seatSixBox,seatSixCardOne,seatSixCardTwo],
            [seatSevenBox,seatSevenCardOne,seatSevenCardTwo],
            [seatEightBox,seatEightCardOne,seatEightCardTwo],
            [seatNineBox,seatNineCardOne,seatNineCardTwo],
            [seatTenBox,seatTenCardOne,seatTenCardTwo]
        ]

        var board = [boardOne, boardTwo, boardThree, boardFour, boardFive]
        
        var players = game.rounds[roundId].players
        
        summaryBox.textStorage?.mutableString.setString("Round \(roundId+1)\n")
        
        for x in 0..<seats.count {

            if let cardOne = seats[x][1] as? NSImageView {
                cardOne.image = players[x].hand.holeCards[0].getImage()
            }
            
            if let cardTwo = seats[x][2] as? NSImageView {
                cardTwo.image = players[x].hand.holeCards[1].getImage()
            }
            
            if players[x].winner == true {
                
                if let seatBox = seats[x][0] as? NSBox {
                    seatBox.borderType = NSBorderType.LineBorder
                    seatBox.borderColor = NSColor.alternateSelectedControlColor()
                    seatBox.borderWidth = 4
                }
                
            } else {
                if let seatBox = seats[x][0] as? NSBox {
                    seatBox.borderWidth = 0
                }
            }
            
            if (players[x].hand.handRank != nil) {
                summaryBox.textStorage?.mutableString.appendString(
                    "Player \(players[x].id) " +
                    String(players[x].hand.handRank!.simpleDescription()) + " "
                )
                
                for card in players[x].hand.cards {
                    summaryBox.textStorage?.mutableString.appendString(card.simpleDescription() + " ")
                }
                    summaryBox.textStorage?.mutableString.appendString("\n")
            }

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

