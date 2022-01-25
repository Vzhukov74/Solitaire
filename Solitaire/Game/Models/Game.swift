//
//  Game.swift
//  Solitaire
//
//  Created by v.s.zhukov on 20.10.2021.
//

import SwiftUI

struct Game: Codable {
    var piles: [Deck]
    var columns: [Deck]
    
    // extra card
    var extraCards: Deck
    var showedCards: Deck = []
    var openCards: Deck = []
        
    init(with deck: Deck = Deck.initial()) {
        var deck = deck.shuffled()
        
        columns = (1...7).compactMap {
            var cards = Array(deck[0..<$0])
            cards[cards.count - 1].isOpen = true
            deck.removeSubrange(0..<$0)
            return cards
        }
        
        piles = [[], [], [], []]
        
        (0..<deck.count).forEach { deck[$0].isOpen = true }
        
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
