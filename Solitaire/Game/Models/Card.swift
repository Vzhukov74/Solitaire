//
//  Card.swift
//  Solitaire
//
//  Created by v.s.zhukov on 21.01.2022.
//

import SwiftUI

typealias Deck = [Card]

struct Card: Hashable, Identifiable {
    enum Suit: CaseIterable {
        case clubs, diamonds, hearts, spades
    }

    enum Rank: Int, CaseIterable {
        case ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king
    }
    
    let id = UUID()
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
