//
//  Game.swift
//  card game
//
//  Created by Владислав Жуков on 21.04.2024.
//

import SwiftUI

class Game: Codable {
    var gCards: [CardViewModel] = []
    var sCards: [[Card]] = []
    
    var gCardsHistory: [[CardViewModel]] = []
    var sCardsHistory: [[[Card]]] = []
    
    var movesNumber: Int = 0
    var timeNumber: Int = 0
    var points: Int = 0
}

struct DeckShuffler {
    let stacks: [[Card]]

    init(with deck: [Card] = Deck.initial()) {
        var deck = deck.shuffled()

        var temp: [[Card]] = (1...7).compactMap {
            var cards = Array(deck[0..<$0])
            deck.removeSubrange(0..<$0)
            return cards
        }
        
        temp.append(deck)
        stacks = temp
    }
    
//    init?(deckStr: String) {
//        let parts = deckStr.split(separator: "|")
//        
//        guard parts.count == 8 else { return nil }
//        
//        func toCards(part: String) -> [Card]? {
//            guard part.count % 2 == 0 else { return nil }
//            
//            let names = part.inserting(every: 2)
//            
//            return names.compactMap { Card(name: $0) }
//        }
//        
//        columns = (0..<7).compactMap { index in
//            toCards(part: String(parts[index]))
//        }
//        
//        guard let extra = toCards(part: String(parts[7])) else { return nil }
//        
//        extraCards = extra
//    }
}

//extension DeckShuffler {
//    var deckStr: String {
//        
//        var str = ""
//        
//        for column in columns {
//            str += column.reduce("", { $0 + $1.name })
//            str += "|"
//        }
//        str += extraCards.reduce("", { $0 + $1.name })
//        
//        return str
//    }
//}
//
//extension String {
//    func inserting(every n: Int) -> [String] {
//        var results: [String] = []
//        let characters = Array(self)
//        stride(from: 0, to: characters.count, by: n).forEach {
//            results.append(String(characters[$0..<min($0+n, characters.count)]))
//
//        }
//        return results
//    }
//}
