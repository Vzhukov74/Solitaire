//
//  Game.swift
//  card game
//
//  Created by Владислав Жуков on 21.04.2024.
//

import SwiftUI

class Game: Codable {
    var gCards: [CardViewModel] = []
    var sCards: [[ShadowCardModel]] = []
    
    var gCardsHistory: [[CardViewModel]] = []
    var sCardsHistory: [[[ShadowCardModel]]] = []
    
    var movesNumber: Int = 0
    var timeNumber: Int = 0
    var points: Int = 0
}

struct DeckShuffler {
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
