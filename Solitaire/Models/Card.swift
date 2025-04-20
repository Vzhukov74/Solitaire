//
//  Card.swift
//  card game
//
//  Created by Владислав Жуков on 21.04.2024.
//

import SwiftUI

struct Card: Codable, Hashable, Identifiable {
    enum Suit: Int, Codable, CaseIterable {
        case clubs, diamonds, hearts, spades
        
        var isRed: Bool { self == .hearts || self == .diamonds }
        
        init?(name: String) {
            switch name {
            case "C":
                self = .clubs
            case "D":
                self = .diamonds
            case "H":
                self = .hearts
            case "S":
                self = .spades
            default: return nil
            }
        }

        init?(title: String) {
            switch title {
            case "♣":
                self = .clubs
            case "♦":
                self = .diamonds
            case "♥︎":
                self = .hearts
            case "♠︎":
                self = .spades
            default: return nil
            }
        }
    }

    enum Rank: Int, Codable, CaseIterable {
        case ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king
        
        init?(name: String) {
            switch name {
            case "A":
                self = .ace
            case "2":
                self = .two
            case "3":
                self = .three
            case "4":
                self = .four
            case "5":
                self = .five
            case "6":
                self = .six
            case "7":
                self = .seven
            case "8":
                self = .eight
            case "9":
                self = .nine
            case "1":
                self = .ten
            case "J":
                self = .jack
            case "Q":
                self = .queen
            case "K":
                self = .king
            default: return nil
            }
        }
    }
    
    var id: String { suit.title + rank.title }
    var name: String { suit.title + rank.title }
    let suit: Suit
    let rank: Rank
    
    init(suit: Suit, rank: Rank) {
        self.rank = rank
        self.suit = suit
    }
    
    init?(name: String) {
        var name = name
        guard let cRankChar = name.popLast(),
              let cSuitChar = name.popLast() else { return nil }
        
        let cRank = String(cRankChar)
        let cSuit = String(cSuitChar)
 
        guard let rank = Card.Rank(name: cRank),
              let suit = Card.Suit(title: cSuit) else { return nil }
        
        self.rank = rank
        self.suit = suit
    }
    
    var next: Card? {
        guard self.rank != .king else { return nil }
        guard let nextRank = Rank(rawValue: self.rank.rawValue + 1) else { return nil }
        
        return Card(suit: self.suit, rank: nextRank)
    }
}

extension Card.Rank {
    var next: Self {
        var nextRaw = rawValue + 1
        if nextRaw > 12 {
            nextRaw = 0
        }
        return Self(rawValue: nextRaw)!
    }
}

extension Card.Suit {
    var title: String {
        switch self {
        case .clubs: return "♣"
        case .diamonds: return "♦"
        case .hearts: return "♥︎"
        case .spades: return "♠︎"
        }
    }
    
    var color: Color {
        switch self {
        case .clubs, .spades: return Color.black
        case .hearts, .diamonds: return Color.red
        }
    }
    
    var colorId: String {
        switch self {
        case .clubs: return "C"
        case .diamonds: return "D"
        case .hearts: return "H"
        case .spades: return "S"
        }
    }
}

extension Card.Rank {
    var title: String {
        switch self {
        case .ace: return "A"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .ten: return "1"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        }
    }
}

extension Card {
    func canStackOn(card: Card, onPile: Bool) -> Bool {
        if onPile {
            return (self.suit == card.suit) && (self.rank.rawValue - 1 == card.rank.rawValue)
        } else {
            return (self.suit.isRed != card.suit.isRed) && (self.rank.rawValue + 1 == card.rank.rawValue)
        }
    }
}

extension Card {
    static func all() -> [Card] {
        Card.Suit.allCases.compactMap { suit in
            Card.Rank.allCases.compactMap { Card(suit: suit, rank: $0) }
        }.flatMap { $0 }
    }
}
