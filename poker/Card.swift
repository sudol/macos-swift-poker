//
//  Card.swift
//  poker
//
//  Created by Paul Sudol on 12/31/15.
//  Copyright © 2015 Paul Sudol. All rights reserved.
//

import Foundation
import AppKit

enum Rank: Int {
    case AltAce = 1
    case Two = 2
    case Three, Four, Five, Six, Seven, Eight, Nine, Ten
    case Jack, Queen, King, Ace
    func simpleDescription() -> String {
        switch self {
        case .AltAce:
            return "A"
        case .Ace:
            return "A"
        case .Jack:
            return "J"
        case .Queen:
            return "Q"
        case .King:
            return "K"
        default:
            return String(self.rawValue)
        }
    }
}

enum Suit: String {
    case Heart, Spade, Diamond, Club
    func simpleDescription() -> String {
        switch self {
        case .Heart:
            return "h"
        case .Spade:
            return "s"
        case .Club:
            return "c"
        case .Diamond:
            return "d"
        }
    }
}

enum HandRanking : Int {
    case HighCard = 1
    case OnePair
    case TwoPair
    case ThreeOfAKind
    case Straight
    case Flush
    case FullHouse
    case FourOfAKind
    case StraightFlush
    case RoyalFlush
    
    func simpleDescription() -> String {
        switch self {
        case HighCard:
            return "High Card"
        case OnePair:
            return "One Pair"
        case TwoPair:
            return "Two Pair"
        case ThreeOfAKind:
            return "Three of a Kind"
        case Straight:
            return "Straight"
        case Flush:
            return "Flush"
        case FullHouse:
            return "Full House"
        case FourOfAKind:
            return "Four of a Kind"
        case StraightFlush:
            return "Straight Flush"
        case RoyalFlush:
            return "Royal Flush"
        }
    }
}

func <(a: HandRanking, b: HandRanking) -> Bool {
    return a.rawValue < b.rawValue
}

func >(a: HandRanking, b: HandRanking) -> Bool {
    return a.rawValue > b.rawValue
}

struct Card {
    var rank: Rank
    var suit: Suit
    
    func simpleDescription() -> String {
        return "\(rank.simpleDescription())\(suit.simpleDescription())"
    }
    
    func imageName() -> String {
        return "\(rank.rawValue)\(suit.simpleDescription())"
    }
    
    func getImage() -> NSImage? {
        return NSImage(named: "\(rank.rawValue)\(suit.simpleDescription())")
    }
}

func <(a: Card, b: Card) -> Bool {
    return a.rank.rawValue < b.rank.rawValue
}

func >(a: Card, b: Card) -> Bool {
    return a.rank.rawValue > b.rank.rawValue
}

func ==(a: Card, b: Card) -> Bool {
    return a.rank.rawValue == b.rank.rawValue
}

func !=(a: Card, b: Card) -> Bool {
    return a.rank.rawValue != b.rank.rawValue
}

func <(a: [Card], b: [Card]) -> Bool {

    for i in 0..<a.count {
        if a[i] < b[i] {
            return true
        } else if a[i] > b[i] {
            return false
        }
    }
    return false
}

func >(a: [Card], b: [Card]) -> Bool {
    
    for i in 0..<a.count {
        if a[i] > b[i] {
            return true
        } else if a[i] < b[i] {
            return false
        }
    }
    return false
}

func ==(a: [Card], b: [Card]) -> Bool {
    
    for i in 0..<a.count {
        if a[i] != b[i] {
            return false
        }
    }
    return true
}

class Deck {
    
    var cards = [Card]()
    
    let timesToLoopForShuffle = 7
    
    init() {
        for x in 2...14 {
            cards += [Card(rank: Rank(rawValue: x)!, suit: .Heart)]
            cards += [Card(rank: Rank(rawValue: x)!, suit: .Spade)]
            cards += [Card(rank: Rank(rawValue: x)!, suit: .Diamond)]
            cards += [Card(rank: Rank(rawValue: x)!, suit: .Club)]
        }
        
        self.shuffle()
    }
    
    func shuffle() {
        var y : Int
        for _ in 1...(timesToLoopForShuffle) {
            for x in 0..<cards.count {
                y = Int(arc4random_uniform(UInt32(cards.count)))
                if x != y {
                    swap(&cards[x], &cards[y])
                }
            }
        }
    }
}
