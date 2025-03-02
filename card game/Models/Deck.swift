//
//  Deck.swift
//  card game
//
//  Created by Владислав Жуков on 21.04.2024.
//

import Foundation

typealias Deck = [Card]

extension Deck {
    static func initial() -> [Card] {
        Card.Suit.allCases.compactMap { suit in
            Card.Rank.allCases.compactMap { Card(suit: suit, rank: $0) }
        }.flatMap { $0 }
    }
}
