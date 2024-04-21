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
    }

    enum Rank: Int, Codable, CaseIterable {
        case ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king
    }
    
    var id: String { suit.title + rank.title }
    let suit: Suit
    let rank: Rank
    var isOpen: Bool = false
    var isHide: Bool = false
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
        case .ten: return "10"
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
