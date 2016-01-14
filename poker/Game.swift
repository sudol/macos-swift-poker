//
//  Game.swift
//  poker
//
//  Created by Paul Sudol on 1/3/16.
//  Copyright © 2016 Paul Sudol. All rights reserved.
//

import Foundation

struct Player {
    var id : Int
    var hand : Hand
    var winner = false
    
    init (id : Int) {
        self.id = id
        hand = Hand()
    }

}

struct Hand {
    var cards = [Card]()
}

class Round {
    var id : Int
    var players : [Player]
    var board = [Card]()
    var deck = Deck()
    
    init(id : Int, players : [Player]) {
        self.id = id
        self.players = players
    }
    
    func deal() {
        for _ in 1...2 {
            for x in 0..<players.count {
                players[x].hand.cards += [deck.cards.removeAtIndex(0)]
            }
        }
    }
    
    func flop() {
        // Burn
        deck.cards.removeAtIndex(0)
        
        // 3 Cards
        board += [deck.cards.removeAtIndex(0)]
        board += [deck.cards.removeAtIndex(0)]
        board += [deck.cards.removeAtIndex(0)]
    }
    
    func turn() {
        // Burn
        deck.cards.removeAtIndex(0)

        // 1 Card
        board += [deck.cards.removeAtIndex(0)]
    }
    
    func river() {
        // Burn
        deck.cards.removeAtIndex(0)
        
        // 1 Card
        board += [deck.cards.removeAtIndex(0)]
        
        evaluate()
    }
    
    func evaluate() {
        players[4].winner = true
    }
}

class Game {
    var players = [Player]()
    var rounds = [Round]()
    
    var currentRoundId = 0
    var currentRound : Round?
    
    init() {
        for x in 1...10 {
            players += [Player(id: x)]
        }
    }
    
    func newRound() {
        currentRound = Round(id: ++currentRoundId, players: players)
        currentRound!.deal()
    }
    
    func saveRound() {
        if currentRound != nil {
            if currentRound?.board.count == 5 {
                rounds += [currentRound!]
            } else {
                print("Cannot save incomplete round")
            }
        }
    }
    
}