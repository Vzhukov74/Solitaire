//
//  Game.swift
//  card game
//
//  Created by Владислав Жуков on 21.04.2024.
//

import SwiftUI

enum DeckShufflerErrors: Error {
    case BadSeckStr
}

struct DeckShuffler {
    let stacks: [[Card]]

    init(with stacks: [[Card]] = Deck.generate()) {
        self.stacks = stacks
    }
    
    init(from: String) throws {
        let parts = from.split(separator: "|")
        
        guard parts.count == 8 else { throw  DeckShufflerErrors.BadSeckStr }
        
        func toCards(part: String) -> [Card]? {
            guard part.count % 2 == 0 else { return nil }
            
            let cards = part.inserting(every: 2).compactMap { Card(name: $0) }
            
            return cards
        }
        
        let temp = (0..<8).compactMap { index in
            toCards(part: String(parts[index]))
        }
        
        stacks = temp
    }
    
    var deckStr: String {
        var str = ""
        
        for stack in stacks {
            str += stack.reduce("", { $0 + $1.name })
            str += "|"
        }
        
        return str
    }
}

extension String {
    func inserting(every n: Int) -> [String] {
        var results: [String] = []
        let characters = Array(self)
        stride(from: 0, to: characters.count, by: n).forEach {
            results.append(String(characters[$0..<min($0+n, characters.count)]))

        }
        return results
    }
}
