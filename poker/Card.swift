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
    case altAce = 1
    case two = 2
    case three, four, five, six, seven, eight, nine, ten
    case jack, queen, king, ace
    func simpleDescription() -> String {
        switch self {
        case .altAce:
            return "A"
        case .ace:
            return "A"
        case .jack:
            return "J"
        case .queen:
            return "Q"
        case .king:
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
    case highCard = 1
    case onePair
    case twoPair
    case threeOfAKind
    case straight
    case flush
    case fullHouse
    case fourOfAKind
    case straightFlush
    case royalFlush
    
    func simpleDescription() -> String {
        switch self {
        case .highCard:
            return "High Card"
        case .onePair:
            return "One Pair"
        case .twoPair:
            return "Two Pair"
        case .threeOfAKind:
            return "Three of a Kind"
        case .straight:
            return "Straight"
        case .flush:
            return "Flush"
        case .fullHouse:
            return "Full House"
        case .fourOfAKind:
            return "Four of a Kind"
        case .straightFlush:
            return "Straight Flush"
        case .royalFlush:
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
        return NSImage(named: NSImage.Name(rawValue: "\(rank.rawValue)\(suit.simpleDescription())"))
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
                    cards.swapAt(x, y)
                }
            }
        }
    }
}
