//
//  Game.swift
//  Solitaire
//
//  Created by v.s.zhukov on 20.10.2021.
//

import SwiftUI

struct Game: Codable {
    let columns: [Deck]
    let extraCards: Deck

    init(with deck: Deck = Deck.initial()) {
        var deck = deck.shuffled()
        
        columns = (1...7).compactMap {
            var cards = Array(deck[0..<$0])
            cards[cards.count - 1].isOpen = true
            deck.removeSubrange(0..<$0)
            return cards
        }

        extraCards = deck
    }
}

extension Deck {
    static func initial() -> Self {
        Card.Suit.allCases.compactMap { suit in
            Card.Rank.allCases.compactMap { Card(suit: suit, rank: $0) }
        }.flatMap { $0 }
    }
}
