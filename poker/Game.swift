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
    var holeCards = [Card]()
    var cards = [Card]()
    var handRank : HandRanking?
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
                players[x].hand.holeCards += [deck.cards.removeAtIndex(0)]
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
//        board += [Card(rank:Rank(rawValue:14)!, suit: .Heart)]
//        board += [Card(rank:Rank(rawValue:2)!, suit: .Spade)]
//        board += [Card(rank:Rank(rawValue:3)!, suit: .Club)]
    }
    
    func turn() {
        // Burn
        deck.cards.removeAtIndex(0)

        // 1 Card
        board += [deck.cards.removeAtIndex(0)]
//        board += [Card(rank:Rank(rawValue:4)!, suit: .Diamond)]
    }
    
    func river() {
        // Burn
        deck.cards.removeAtIndex(0)
        
        // 1 Card
        board += [deck.cards.removeAtIndex(0)]
//        board += [Card(rank:Rank(rawValue:5)!, suit: .Heart)]
        
        evaluate()
    }
    
    func evaluate() {
        
        for (index,player) in players.enumerate() {
            let hand = rankHand(player.hand, board: board)
            players[index].hand.handRank = hand.0
            players[index].hand.cards = hand.1
        }
        
        /*
        Find the highest handRank among all players.
        */
        var highestHandRank = HandRanking.HighCard;
        for player in players {
            //I should be able to do this without RawValue... wtf
            if player.hand.handRank! > highestHandRank {
                highestHandRank = player.hand.handRank!
            }
        }

        /*
        Get a list of all the players with that handRank
        */
        var winners = [Player]()
        for player in players {
            if player.hand.handRank == highestHandRank {
                winners.append(player)
            }
        }
        
        if winners.count > 1 {
            var realWinners = [Player]()
            for player in winners {
                if realWinners.count < 1 {
                    realWinners.append(player)
                } else {
                    for winner in realWinners {
                        if player.hand.cards > winner.hand.cards {
                            realWinners = [player]
                        } else if player.hand.cards == winner.hand.cards {
                            realWinners += [player]
                        }
                    }
                }
            }
            for player in realWinners {
                players[players.indexOf({$0.id == player.id})!].winner = true
            }
        } else {
            players[players.indexOf({$0.id == winners[0].id})!].winner = true
        }
    }
    
    func rankHand(hand : Hand, board : [Card]) -> (HandRanking?, [Card]) {

        var result = checkForRoyalFlush(hand.holeCards + board)
        if (result.0 == true) {
//            print("Round \(id) Royal Flush")
            return (HandRanking.RoyalFlush, result.1)
        }

        result = checkForStraightFlush(hand.holeCards + board)
        if (result.0 == true) {
            return (HandRanking.StraightFlush, result.1)
        }
        
        result = checkForFourOfAKind(hand.holeCards + board)
        if (result.0 == true) {
            return (HandRanking.FourOfAKind, result.1)
        }

        result = checkForFullHouse(hand.holeCards + board)
        if (result.0 == true) {
            return (HandRanking.FullHouse, result.1)
        }
        
        result = checkForFlush(hand.holeCards + board)
        if (result.0 == true) {
            /*
            The flush check can return more than 5 cards because it is used
            to find straight flushes as well.
            */
            while (result.1.count != 5) {
                result.1.popLast()
            }
            return (HandRanking.Flush, result.1)
        }
        
        result = checkForStraight(hand.holeCards + board)
        if (result.0 == true) {
            return (HandRanking.Straight, result.1)
        }

        result = checkForThreeOfAKind(hand.holeCards + board)
        if (result.0 == true) {
            return (HandRanking.ThreeOfAKind, result.1)
        }
        
        result = checkForTwoPair(hand.holeCards + board)
        if (result.0 == true) {
            return (HandRanking.TwoPair, result.1)
        }

        result = checkForOnePair(hand.holeCards + board)
        if (result.0 == true) {
            return (HandRanking.OnePair, result.1)
        }
        
        var bestHand = hand.holeCards + board
        bestHand.sortInPlace({$0.rank.rawValue > $1.rank.rawValue})

        return (HandRanking.HighCard, Array(bestHand[0...4]))
        
    }
    
    func checkForRoyalFlush(hand : [Card]) -> (Bool, [Card]) {
        let result = checkForStraightFlush(hand)
        if result.0 == true {
            if result.1.first?.rank.rawValue == 14 {
                return (true, result.1)
            }
        }
        
        return (false, hand)
    }
    
    func checkForStraightFlush(hand : [Card]) -> (Bool, [Card]) {
        let result = checkForFlush(hand)
        if result.0 == true {
            let nextResult = checkForStraight(result.1)
            if nextResult.0 == true {
                return (true, nextResult.1)
            }
        }
        
        return (false, hand)
    }

    func checkForFourOfAKind(var hand : [Card]) -> (Bool, [Card]) {

        let cardsGroupedByRank = groupCardsByRank(hand)
        
        //Find a rank that has 4 cards in it
        for cardsOfARank in cardsGroupedByRank {
            if (cardsOfARank.count == 4) {
                /*
                Remove the four of a kind from the hand and get the highest
                remaining card
                */
                for card in cardsOfARank {
                    let cardToRemove = hand.indexOf({$0.rank.rawValue == card.rank.rawValue})
                    hand.removeAtIndex(cardToRemove!)
                }
                
                hand.sortInPlace({$0.rank.rawValue > $1.rank.rawValue})
                
                return (true, cardsOfARank + [hand[0]])
            }
        }
        
        return (false, hand)
    }
    
    func checkForFullHouse(var hand : [Card]) -> (Bool, [Card]) {
        let cardsGroupedByRank = groupCardsByRank(hand)
        
        var bestHand = [Card]()
        //Find a rank that has 3 cards in it
        for cardsOfARank in cardsGroupedByRank {
            if (cardsOfARank.count == 3) {
                /*
                Remove the three of a kind from the hand and get the highest
                remaining cards
                */
                for card in cardsOfARank {
                    let cardToRemove = hand.indexOf({$0.rank.rawValue == card.rank.rawValue})
                    bestHand.append(hand.removeAtIndex(cardToRemove!))
                }

                //Group the remaining cards and look for the highest pair
                let remainingCards = groupCardsByRank(hand)
                
                for remainingCardsOfARank in remainingCards {
                    if (remainingCardsOfARank.count > 1) {
                        /*
                        Just using 2 cards, it is possible to have another 
                        three of a kind
                        */
                        bestHand.append(remainingCardsOfARank[0])
                        bestHand.append(remainingCardsOfARank[1])
                        
                        return (true, bestHand)
                    }
                }
                
                /*
                Can return here because we found three of a kind, but didn't
                find another pair
                */
                return (false, hand)
            }
        }
        
        return (false, hand)
    }
    
    func checkForFlush(hand : [Card]) -> (Bool, [Card]) {
        var hearts = [Card](), spades = [Card]() , diamonds = [Card](), clubs = [Card]()
        for card in hand {
            switch card.suit {
            case .Heart:
                hearts.append(card)
            case .Spade:
                spades.append(card)
            case .Diamond:
                diamonds.append(card)
            case .Club:
                clubs.append(card)
            }
        }
        
        hearts.sortInPlace({$0.rank.rawValue > $1.rank.rawValue})
        spades.sortInPlace({$0.rank.rawValue > $1.rank.rawValue})
        diamonds.sortInPlace({$0.rank.rawValue > $1.rank.rawValue})
        clubs.sortInPlace({$0.rank.rawValue > $1.rank.rawValue})
        
        if hearts.count > 4 {
            return (true, hearts)
        } else if spades.count > 4 {
            return (true, spades)
        } else if diamonds.count > 4 {
            return (true, diamonds)
        } else if clubs.count > 4 {
            return (true, clubs)
        } else {
            return (false, hand)
        }
    }
    
    func checkForStraight(var hand : [Card]) -> (Bool, [Card]) {
        
        hand = removeDuplicateRanks(hand)
        hand.sortInPlace({$0.rank.rawValue > $1.rank.rawValue})
        
        for (index,card) in hand.enumerate() {
            
            //Check if the raw value of the next card is one less that this value
            if index + 4 < hand.count
                && hand[index+1].rank.rawValue == card.rank.rawValue - 1
                && hand[index+2].rank.rawValue == card.rank.rawValue - 2
                && hand[index+3].rank.rawValue == card.rank.rawValue - 3
                && hand[index+4].rank.rawValue == card.rank.rawValue - 4
            {
                return (true, Array(hand[index...index+4]))
            }
        }
        
        //Try the same thing, with the Ace as 1 instead of 14
        
        if let aceIndex = hand.indexOf({$0.rank.rawValue == 14}) {
            hand[aceIndex].rank = .AltAce
            hand.sortInPlace({$0.rank.rawValue > $1.rank.rawValue})
            
            for (index,card) in hand.enumerate() {
                
                //Check if the raw value of the next card is one less that this value
                if index + 4 < hand.count
                    && hand[index+1].rank.rawValue == card.rank.rawValue - 1
                    && hand[index+2].rank.rawValue == card.rank.rawValue - 2
                    && hand[index+3].rank.rawValue == card.rank.rawValue - 3
                    && hand[index+4].rank.rawValue == card.rank.rawValue - 4
                {
                    return (true, Array(hand[index...index+4]))
                }
            }
            
            //If there is no straight, set the Ace back to it's regular rank
            hand[aceIndex].rank = .Ace
            hand.sortInPlace({$0.rank.rawValue > $1.rank.rawValue})
        }
        
        
        return (false, hand)
    }

    func checkForThreeOfAKind(var hand : [Card]) -> (Bool, [Card]) {
        let cardsGroupedByRank = groupCardsByRank(hand)
        
        //Find a rank that has 3 cards in it
        for cardsOfARank in cardsGroupedByRank {
            if (cardsOfARank.count == 3) {
                /*
                Remove the three of a kind from the hand and get the highest
                remaining cards
                */
                for card in cardsOfARank {
                    let cardToRemove = hand.indexOf({$0.rank.rawValue == card.rank.rawValue})
                    hand.removeAtIndex(cardToRemove!)
                }
                
                hand.sortInPlace({$0.rank.rawValue > $1.rank.rawValue})
                
                return (true, cardsOfARank + hand[0...1])
            }
        }
        
        return (false, hand)
    }

    func checkForTwoPair(var hand : [Card]) -> (Bool, [Card]) {
        let cardsGroupedByRank = groupCardsByRank(hand)
        
        var bestHand = [Card]()
        var pairsFound = 0
        //Find highest rank that has 2 cards in it
        for cardsOfARank in cardsGroupedByRank {
            if (cardsOfARank.count == 2 && pairsFound < 2) {
                /*
                Remove the pair from the hand and get the highest remaining cards
                */
                for card in cardsOfARank {
                    let cardToRemove = hand.indexOf({$0.rank.rawValue == card.rank.rawValue})
                    bestHand.append(hand.removeAtIndex(cardToRemove!))
                }
                
                pairsFound++

            }
        }
        
        if (pairsFound == 2) {
            hand.sortInPlace({$0.rank.rawValue > $1.rank.rawValue})
            return (true, bestHand + [hand[0]])
        }
        
        return (false, hand)
    }

    func checkForOnePair(var hand : [Card]) -> (Bool, [Card]) {
        let cardsGroupedByRank = groupCardsByRank(hand)
        
        var bestHand = [Card]()

        //Find highest rank that has 2 cards in it
        for cardsOfARank in cardsGroupedByRank {
            if (cardsOfARank.count == 2) {
                /*
                Remove the pair from the hand and get the highest remaining cards
                */
                for card in cardsOfARank {
                    let cardToRemove = hand.indexOf({$0.rank.rawValue == card.rank.rawValue})
                    bestHand.append(hand.removeAtIndex(cardToRemove!))
                }
                
                hand.sortInPlace({$0.rank.rawValue > $1.rank.rawValue})
                return (true, bestHand + hand[0...2])
                
            }
        }
        
        return (false, hand)
    }
    
    func groupCardsByRank(cards : [Card]) -> [[Card]] {
        //Make an array with keys as card ranks
        var ranks = Array(count: 15, repeatedValue : [Card]())
        
        //Add each card to the array of ranks
        for card in cards {
            ranks[card.rank.rawValue].append(card)
        }

        return ranks.reverse()
    }
    
    func removeDuplicateRanks(cards : [Card]) -> [Card] {
        
        var cardsCopy = cards
        var ranks = [Int]()
        
        for card in cards {
            if (ranks.indexOf(card.rank.rawValue) != nil) {
                cardsCopy.removeAtIndex(
                    cardsCopy.indexOf({$0.rank.rawValue == card.rank.rawValue})!
                )
            } else {
                ranks += [card.rank.rawValue]
            }
        }
        
        return cardsCopy
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