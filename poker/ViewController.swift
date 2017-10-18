//
//  ViewController.swift
//  poker
//
//  Created by Paul Sudol on 12/31/15.
//  Copyright © 2015 Paul Sudol. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate{

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
    
    @IBOutlet var numberOfRounds: NSTextField!
//    @IBOutlet var numberOfRoundsFormatter: NSNumberFormatter!
    
    @IBOutlet var generateButton: NSButton!
    
    @IBOutlet var table: NSTableView!
    
    @IBOutlet var royalFlushCount: NSTextField!
    @IBOutlet var straightFlushCount: NSTextField!
    @IBOutlet var fourOfAKindCount: NSTextField!
    @IBOutlet var fullHouseCount: NSTextField!
    @IBOutlet var flushCount: NSTextField!
    @IBOutlet var straightCount: NSTextField!
    @IBOutlet var threeOfAKindCount: NSTextField!
    @IBOutlet var twoPairCount: NSTextField!
    @IBOutlet var onePairCount: NSTextField!
    @IBOutlet var highCardCount: NSTextField!
    
    @IBOutlet var progressBar: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewWillAppear() {
        if (table != nil) {
            table.reloadData()
        }
        
//        print(numberOfRoundsFormatter.maximumIntegerDigits)
    }
    
    @IBAction func generateRounds(_ sender: NSButton) {
        let priority = DispatchQueue.GlobalQueuePriority.default
        
        generateButton.isEnabled = false
        progressBar.startAnimation(self)
        let rounds = numberOfRounds.integerValue
        
        DispatchQueue.global(priority: priority).async {
            
            
            game = Game()
            
            var summary : [HandRanking:Int] = [
                HandRanking.royalFlush : 0,
                HandRanking.straightFlush : 0,
                HandRanking.fourOfAKind : 0,
                HandRanking.fullHouse : 0,
                HandRanking.flush: 0,
                HandRanking.straight : 0,
                HandRanking.threeOfAKind : 0,
                HandRanking.twoPair : 0,
                HandRanking.onePair : 0,
                HandRanking.highCard : 0
            ]
            
            for _ in 1...rounds {
                game.newRound()
                
                game.currentRound!.flop()
                game.currentRound!.turn()
                game.currentRound!.river()
                
                for player in game.currentRound!.players {
                    summary[player.hand.handRank!] = summary[player.hand.handRank!]! + 1
                }
                
                game.saveRound()
            }
            
            DispatchQueue.main.async {
                self.progressBar.stopAnimation(self)
                self.generateButton.isEnabled = true
                
                self.royalFlushCount.integerValue = summary[HandRanking.royalFlush]!
                self.straightFlushCount.integerValue = summary[HandRanking.straightFlush]!
                self.fourOfAKindCount.integerValue = summary[HandRanking.fourOfAKind]!
                self.fullHouseCount.integerValue = summary[HandRanking.fullHouse]!
                self.flushCount.integerValue = summary[HandRanking.flush]!
                self.straightCount.integerValue = summary[HandRanking.straight]!
                self.threeOfAKindCount.integerValue = summary[HandRanking.threeOfAKind]!
                self.twoPairCount.integerValue = summary[HandRanking.twoPair]!
                self.onePairCount.integerValue = summary[HandRanking.onePair]!
                self.highCardCount.integerValue = summary[HandRanking.highCard]!
            }
            
        }


    }
    
    
    func showRound(_ roundId: Int) {
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
                    seatBox.borderType = NSBorderType.lineBorder
                    seatBox.borderColor = NSColor.alternateSelectedControlColor
                    seatBox.borderWidth = 4
                }
                
            } else {
                if let seatBox = seats[x][0] as? NSBox {
                    seatBox.borderWidth = 0
                }
            }
            
            if (players[x].hand.handRank != nil) {
                summaryBox.textStorage?.mutableString.append(
                    "Player \(players[x].id) " +
                    String(players[x].hand.handRank!.simpleDescription()) + " "
                )
                
                for card in players[x].hand.cards {
                    summaryBox.textStorage?.mutableString.append(card.simpleDescription() + " ")
                }
                    summaryBox.textStorage?.mutableString.append("\n")
            }

        }
        
        for x in 0..<board.count {
            board[x]?.image = game.rounds[roundId].board[x].getImage()
        }
    }
    
    //MARK: NSTextFieldDelegate
    override func controlTextDidChange(_ obj: Notification) {
        if (numberOfRounds.integerValue > 1) {
            generateButton.isEnabled = true
        } else {
            generateButton.isEnabled = false
        }
    }
    
    //MARK: NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return game.rounds.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView: NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        
        if tableColumn!.identifier.rawValue == "roundId" {
            let roundId = row
            let round = game.rounds[roundId]
            let winningHand = round.players.first { $0.winner }!.hand
            cellView.textField!.stringValue = "Hand \(round.id) : \(winningHand.handRank!.simpleDescription())"
            
            return cellView
        }
        
        return cellView
    }
    
    //MARK: NSTableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
        showRound(((notification.object as AnyObject).selectedRow)!)
    }
    
}

