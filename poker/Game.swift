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
                players[x].hand.holeCards += [deck.cards.remove(at: 0)]
            }
        }
    }
    
    func flop() {
        // Burn
        deck.cards.remove(at: 0)
        
        // 3 Cards
        board += [deck.cards.remove(at: 0)]
        board += [deck.cards.remove(at: 0)]
        board += [deck.cards.remove(at: 0)]
//        board += [Card(rank:Rank(rawValue:14)!, suit: .Heart)]
//        board += [Card(rank:Rank(rawValue:2)!, suit: .Spade)]
//        board += [Card(rank:Rank(rawValue:3)!, suit: .Club)]
    }
    
    func turn() {
        // Burn
        deck.cards.remove(at: 0)

        // 1 Card
        board += [deck.cards.remove(at: 0)]
//        board += [Card(rank:Rank(rawValue:4)!, suit: .Diamond)]
    }
    
    func river() {
        // Burn
        deck.cards.remove(at: 0)
        
        // 1 Card
        board += [deck.cards.remove(at: 0)]
//        board += [Card(rank:Rank(rawValue:5)!, suit: .Heart)]
        
        evaluate()
    }
    
    func evaluate() {
        
        for (index,player) in players.enumerated() {
            let hand = rankHand(player.hand, board: board)
            players[index].hand.handRank = hand.rank
            players[index].hand.cards = hand.cards
        }
        
        /*
        Find the highest handRank among all players.
        */
        var highestHandRank = HandRanking.highCard;
        for player in players {
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
                players[players.index(where: {$0.id == player.id})!].winner = true
            }
        } else {
            players[players.index(where: {$0.id == winners[0].id})!].winner = true
        }
    }

    struct HandEvaluation {
        let rank: HandRanking
        let cards: [Card]
        init(_ rank: HandRanking, cards: [Card]) {
            self.rank = rank
            self.cards = cards
        }
    }

    func rankHand(_ hand : Hand, board : [Card]) -> HandEvaluation {
        let allCards = hand.holeCards + board
        if case let .success(cards) = checkForRoyalFlush(allCards) {
            return HandEvaluation(.royalFlush, cards: cards)
        }

        if case let .success(cards) = checkForStraightFlush(allCards) {
            return HandEvaluation(.straightFlush, cards: cards)
        }

        if case let .success(cards) = checkForFourOfAKind(allCards) {
            return HandEvaluation(.fourOfAKind, cards: cards)
        }

        if case let .success(cards) = checkForFullHouse(allCards) {
            return HandEvaluation(.fourOfAKind, cards: cards)
        }

        if case let .success(cards) = checkForFlush(allCards) {
            var flushCards = cards
            /*
             The flush check can return more than 5 cards because it is used
             to find straight flushes as well.
             */

            while (flushCards.count != 5) {
                _ = flushCards.popLast()
            }

            return HandEvaluation(.flush, cards: flushCards)
        }

        if case let .success(cards) = checkForStraight(allCards) {
            return HandEvaluation(.straight, cards: cards)
        }

        if case let .success(cards) = checkForThreeOfAKind(allCards) {
            return HandEvaluation(.threeOfAKind, cards: cards)
        }

        if case let .success(cards) = checkForTwoPair(allCards) {
            return HandEvaluation(.twoPair, cards: cards)
        }

        if case let .success(cards) = checkForOnePair(allCards) {
            return HandEvaluation(.onePair, cards: cards)
        }


        var bestHand = hand.holeCards + board
        bestHand.sort(by: {$0.rank.rawValue > $1.rank.rawValue})

        return HandEvaluation(.highCard, cards: Array(bestHand[0...4]))
        
    }
    enum CheckResult {
        case failed
        case success([Card])
    }
    
    func checkForRoyalFlush(_ hand : [Card]) -> CheckResult {
        if case let .success(cards) = checkForStraightFlush(hand) {
            if cards.first?.rank == .ace {
                return .success(cards)
            }
        }
        return .failed
    }
    
    func checkForStraightFlush(_ hand : [Card]) -> CheckResult {
        if case let .success(cards) = checkForFlush(hand) {
            if case let .success(straignt) = checkForStraight(cards) {
                return .success(straignt)
            }
        }
        return .failed
    }

    func checkForFourOfAKind(_ hand : [Card]) -> CheckResult {
        var hand = hand

        let cardsGroupedByRank = groupCardsByRank(hand)
        
        //Find a rank that has 4 cards in it
        for cardsOfARank in cardsGroupedByRank {
            if (cardsOfARank.count == 4) {
                /*
                Remove the four of a kind from the hand and get the highest
                remaining card
                */
                for card in cardsOfARank {
                    let cardToRemove = hand.index(where: {$0.rank.rawValue == card.rank.rawValue})
                    hand.remove(at: cardToRemove!)
                }
                
                hand.sort(by: {$0.rank.rawValue > $1.rank.rawValue})
                
                return .success(cardsOfARank + [hand[0]])
            }
        }
        
        return .failed
    }
    
    func checkForFullHouse(_ hand : [Card]) -> CheckResult {
        var hand = hand
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
                    let cardToRemove = hand.index(where: {$0.rank.rawValue == card.rank.rawValue})
                    bestHand.append(hand.remove(at: cardToRemove!))
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
                        
                        return .success(bestHand)
                    }
                }
                
                /*
                Can return here because we found three of a kind, but didn't
                find another pair
                */
                return .failed
            }
        }
        
        return .failed
    }
    
    func checkForFlush(_ hand : [Card]) -> CheckResult {
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
        
        hearts.sort(by: {$0.rank.rawValue > $1.rank.rawValue})
        spades.sort(by: {$0.rank.rawValue > $1.rank.rawValue})
        diamonds.sort(by: {$0.rank.rawValue > $1.rank.rawValue})
        clubs.sort(by: {$0.rank.rawValue > $1.rank.rawValue})
        
        if hearts.count > 4 {
            return .success(hearts)
        } else if spades.count > 4 {
            return .success(spades)
        } else if diamonds.count > 4 {
            return .success(diamonds)
        } else if clubs.count > 4 {
            return .success(clubs)
        } else {
            return .failed
        }
    }
    
    func checkForStraight(_ hand : [Card]) -> CheckResult {
        var hand = hand
        
        hand = removeDuplicateRanks(hand)
        hand.sort(by: {$0.rank.rawValue > $1.rank.rawValue})
        
        for (index,card) in hand.enumerated() {
            
            //Check if the raw value of the next card is one less that this value
            if index + 4 < hand.count
                && hand[index+1].rank.rawValue == card.rank.rawValue - 1
                && hand[index+2].rank.rawValue == card.rank.rawValue - 2
                && hand[index+3].rank.rawValue == card.rank.rawValue - 3
                && hand[index+4].rank.rawValue == card.rank.rawValue - 4
            {
                return .success(Array(hand[index...index+4]))
            }
        }
        
        //Try the same thing, with the Ace as 1 instead of 14
        
        if let aceIndex = hand.index(where: {$0.rank.rawValue == 14}) {
            hand[aceIndex].rank = .altAce
            hand.sort(by: {$0.rank.rawValue > $1.rank.rawValue})
            
            for (index,card) in hand.enumerated() {
                
                //Check if the raw value of the next card is one less that this value
                if index + 4 < hand.count
                    && hand[index+1].rank.rawValue == card.rank.rawValue - 1
                    && hand[index+2].rank.rawValue == card.rank.rawValue - 2
                    && hand[index+3].rank.rawValue == card.rank.rawValue - 3
                    && hand[index+4].rank.rawValue == card.rank.rawValue - 4
                {
                    return .success(Array(hand[index...index+4]))
                }
            }
            
            //If there is no straight, set the Ace back to it's regular rank
            hand[aceIndex].rank = .ace
            hand.sort(by: {$0.rank.rawValue > $1.rank.rawValue})
        }
        
        
        return .failed
    }

    func checkForThreeOfAKind(_ hand : [Card]) -> CheckResult {
        var hand = hand
        let cardsGroupedByRank = groupCardsByRank(hand)
        
        //Find a rank that has 3 cards in it
        for cardsOfARank in cardsGroupedByRank {
            if (cardsOfARank.count == 3) {
                /*
                Remove the three of a kind from the hand and get the highest
                remaining cards
                */
                for card in cardsOfARank {
                    let cardToRemove = hand.index(where: {$0.rank.rawValue == card.rank.rawValue})
                    hand.remove(at: cardToRemove!)
                }
                
                hand.sort(by: {$0.rank.rawValue > $1.rank.rawValue})
                
                return .success(cardsOfARank + hand[0...1])
            }
        }
        
        return .failed
    }

    func checkForTwoPair(_ hand : [Card]) -> CheckResult {
        var hand = hand
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
                    let cardToRemove = hand.index(where: {$0.rank.rawValue == card.rank.rawValue})
                    bestHand.append(hand.remove(at: cardToRemove!))
                }
                
                pairsFound += 1

            }
        }
        
        if (pairsFound == 2) {
            hand.sort(by: {$0.rank.rawValue > $1.rank.rawValue})
            return .success(bestHand + [hand[0]])
        }
        
        return .failed
    }

    func checkForOnePair(_ hand : [Card]) -> CheckResult {
        var hand = hand
        let cardsGroupedByRank = groupCardsByRank(hand)
        
        var bestHand = [Card]()

        //Find highest rank that has 2 cards in it
        for cardsOfARank in cardsGroupedByRank {
            if (cardsOfARank.count == 2) {
                /*
                Remove the pair from the hand and get the highest remaining cards
                */
                for card in cardsOfARank {
                    let cardToRemove = hand.index(where: {$0.rank.rawValue == card.rank.rawValue})
                    bestHand.append(hand.remove(at: cardToRemove!))
                }
                
                hand.sort(by: {$0.rank.rawValue > $1.rank.rawValue})
                return .success(bestHand + hand[0...2])
                
            }
        }
        
        return .failed
    }
    
    func groupCardsByRank(_ cards : [Card]) -> [[Card]] {
        //Make an array with keys as card ranks
        var ranks = Array(repeating: [Card](), count: 15)
        
        //Add each card to the array of ranks
        for card in cards {
            ranks[card.rank.rawValue].append(card)
        }

        return ranks.reversed()
    }
    
    func removeDuplicateRanks(_ cards : [Card]) -> [Card] {
        
        var cardsCopy = cards
        var ranks = [Int]()
        
        for card in cards {
            if (ranks.index(of: card.rank.rawValue) != nil) {
                cardsCopy.remove(
                    at: cardsCopy.index(where: {$0.rank.rawValue == card.rank.rawValue})!
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
        currentRoundId += 1
        currentRound = Round(id: currentRoundId, players: players)
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
