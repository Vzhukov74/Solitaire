//
//  Deck.swift
//  Solitaire
//
//  Created by Vladislav Zhukov on 06.05.2025.
//

struct Deck {
    static func generate() -> [[Card]] {
        var deck = Card.all().shuffled()

        var temp: [[Card]] = (1...7).compactMap {
            let cards = Array(deck[0..<$0])
            deck.removeSubrange(0..<$0)
            return cards
        }
        temp.append(deck)
        
        if Deck.isRight(stacks: temp) {
            return temp
        } else {
            return generate()
        }
    }
    
    private static func isRight(stacks: [[Card]]) -> Bool {
        var red = Card.Rank.allCases
        var black = Card.Rank.allCases

        for stackIndex in stacks.indices {
            if stackIndex < 7, let card = stacks[stackIndex].last {
                Deck.filter(for: card, red: &red, black: &black)
            } else {
                stacks[stackIndex].forEach { card in
                    Deck.filter(for: card, red: &red, black: &black)
                }
            }
        }

        return red.isEmpty && black.isEmpty
    }
    
    private static func filter(for card: Card, red: inout [Card.Rank], black: inout [Card.Rank]) {
        if card.suit == .diamonds || card.suit == .hearts {
            red.removeAll(where: { $0 == card.rank })
        } else {
            black.removeAll(where: { $0 == card.rank })
        }
    }
}
