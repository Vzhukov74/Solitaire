//
//  Game.swift
//  Solitaire
//
//  Created by v.s.zhukov on 20.10.2021.
//

import SwiftUI

class Game: ObservableObject {
    @Published var piles = [Pile(), Pile(), Pile(), Pile()]
    @Published var columns: [Column]
    @Published var extra: Extra
    
    @Published var movingCards: MovingCards?
    
    init(with deck: Deck = Deck.initial()) {
        var deck = deck.shuffled()
        
        columns = (1...7).compactMap {
            var cards = Array(deck[0..<$0])
            cards[cards.count - 1].isOpen = true
            deck.removeSubrange(0..<$0)
            return Column(cards: cards)
        }
        
        (0..<deck.count).forEach { deck[$0].isOpen = true }
        
        extra = Extra(cards: deck)
    }
    
    func move(card: Card, at position: CGPoint) {
        if movingCards != nil {
            movingCards?.position = position
        } else {
            var movingCards = findMovingCards(by: card)
            hide(movingCards: movingCards)
            movingCards?.position = position
            self.movingCards = movingCards
        }
    }
    
    func stack(card: Card, at position: CGPoint) {
        guard let movingCards = movingCards else { return }
        
        let columnEndIndex = Int(position.x / (UIScreen.main.bounds.width / 7))
        
        var cards = movingCards.cards
        
        if position.y < (UIScreen.main.bounds.width / 7) * 1.5, columnEndIndex <= 3 {
            if piles[columnEndIndex].canStack(card: cards.first!) {
                cards.indices.forEach { cards[$0].isHide = false }
                piles[columnEndIndex].cards.append(contentsOf: cards)
                
                removeFromStartStack(movingCards: movingCards)
            } else {
                backCardsToStartStack()
            }
        } else {
            let columnEndIndex = Int(position.x / (UIScreen.main.bounds.width / 7))

            if columns[columnEndIndex].canStack(card: cards.first!) {
                cards.indices.forEach { cards[$0].isHide = false }
                columns[columnEndIndex].cards.append(contentsOf: cards)
                
                removeFromStartStack(movingCards: movingCards)
            } else {
                backCardsToStartStack()
            }
        }
        self.movingCards = nil
    }
    
    func onTap(card: Card) {
        guard let movingCards = findMovingCards(by: card) else { return }

        if movingCards.cards.count == 1 {
            for index in piles.indices {
                if piles[index].canStack(card: movingCards.cards.first!) {
                    withAnimation {
                        piles[index].cards.append(contentsOf: movingCards.cards)
                        removeFromStartStack(movingCards: movingCards)
                    }
                    return
                }
            }
        }
        
        for index in columns.indices {
            if columns[index].canStack(card: movingCards.cards.first!) {
                withAnimation {
                    columns[index].cards.append(contentsOf: movingCards.cards)
                    removeFromStartStack(movingCards: movingCards)
                }
                return
            }
        }
    }
    
    func openCard() {
        if extra.cards.isEmpty {
            extra.cards = extra.openCards + extra.toShowCards
            extra.openCards = []
            extra.toShowCards = []
        } else {
            let card = extra.cards.popLast()
            
            if extra.toShowCards.count < 3 {
                extra.toShowCards.insert(card!, at: 0)
            } else {
                extra.openCards.append(extra.toShowCards.popLast()!)
                extra.toShowCards.insert(card!, at: 0)
            }
        }
    }
    
    private func findMovingCards(by card: Card) -> MovingCards? {
        if let columnIndex = columns.firstIndex(where: { $0.cards.contains(card) }) {
            guard let cardIndex = columns[columnIndex].cards.firstIndex(where: { $0.id == card.id }) else { return nil }
                    
            let cards = Array(columns[columnIndex].cards[cardIndex..<columns[columnIndex].cards.count])
            
            return MovingCards(cards: cards, stackType: .column, stackIndex: columnIndex, cardIndex: cardIndex, position: .zero)
        } else if extra.toShowCards.contains(card) {
            guard extra.toShowCards.first?.id == card.id else { return nil }
                        
            return MovingCards(cards: [card], stackType: .extra, stackIndex: 0, cardIndex: 0, position: .zero)
        } else if let pileIndex = piles.firstIndex(where: { $0.cards.contains(card)}) {
            guard let cardIndex = piles[pileIndex].cards.firstIndex(where: { $0.id == card.id }) else { return nil }
            
            let cards = Array(piles[pileIndex].cards[cardIndex..<piles[pileIndex].cards.count])
            
            return MovingCards(cards: cards, stackType: .pile, stackIndex: pileIndex, cardIndex: cardIndex, position: .zero)
        }
        return nil
    }
    
    private func hide(movingCards: MovingCards?) {
        guard let movingCards = movingCards else { return }
        switch movingCards.stackType {
        case .pile:
            (movingCards.cardIndex..<piles[movingCards.stackIndex].cards.count).forEach {
                piles[movingCards.stackIndex].cards[$0].isHide = true
            }
        case .extra:
            extra.toShowCards[0].isHide = true
        case .column:
            (movingCards.cardIndex..<columns[movingCards.stackIndex].cards.count).forEach {
                columns[movingCards.stackIndex].cards[$0].isHide = true
            }
        }
    }
    
//    private func unhide(movingCards: MovingCards?) {
//        guard let movingCards = movingCards else { return }
//        switch movingCards.stackType {
//        case .pile:
//            (movingCards.cardIndex..<piles[movingCards.stackIndex].cards.count).forEach {
//                piles[movingCards.stackIndex].cards[$0].isHide = false
//            }
//        case .extra:
//            extra.toShowCards[0].isHide = false
//        case .column:
//            (movingCards.cardIndex..<columns[movingCards.stackIndex].cards.count).forEach {
//                columns[movingCards.stackIndex].cards[$0].isHide = false
//            }
//        }
//    }
    
    private func removeFromStartStack(movingCards: MovingCards) {
        switch movingCards.stackType {
        case .pile:
            piles[movingCards.stackIndex].cards.removeLast()
        case .extra:
            extra.toShowCards.removeFirst()
        case .column:
            columns[movingCards.stackIndex].cards.removeSubrange(movingCards.cardIndex..<columns[movingCards.stackIndex].cards.count)

            let lastCardIndex = columns[movingCards.stackIndex].cards.count - 1
            if lastCardIndex >= 0, !columns[movingCards.stackIndex].cards.isEmpty {
                columns[movingCards.stackIndex].cards[lastCardIndex].isOpen = true
            }
        }
    }
        
    private func backCardsToStartStack() {
        guard let movingCards = movingCards else { return }
        switch movingCards.stackType {
        case .pile:
            piles[movingCards.stackIndex].cards[piles[movingCards.stackIndex].cards.count - 1].isHide = false
        case .extra:
            extra.toShowCards[0].isHide = false
        case .column:
            (movingCards.cardIndex..<columns[movingCards.stackIndex].cards.count).forEach {
                columns[movingCards.stackIndex].cards[$0].isHide = false
            }
        }
    }
}

struct Column {
    var cards: [Card]
    
    func canStack(card: Card) -> Bool {
        if let _card = cards.last {
            if ((_card.suit == .clubs || _card.suit == .spades) && (card.suit == .hearts || card.suit == .diamonds)) ||
                ((_card.suit == .hearts || _card.suit == .diamonds) && (card.suit == .clubs || card.suit == .spades)) {
                if _card.rank.rawValue == card.rank.rawValue + 1 {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else if card.rank == .king {
            return true
        } else {
            return false
        }
    }
}

struct Pile {
    var cards: [Card] = []
    
    func canStack(card: Card) -> Bool {
        if let _card = cards.last {
            if _card.suit == card.suit {
                if _card.rank.rawValue == card.rank.rawValue - 1 {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else if card.rank == .ace {
            return true
        } else {
            return false
        }
    }
}

struct Extra {
    var cards: [Card]
    var openCards: [Card] = []
    var toShowCards: [Card] = []
}

struct MovingCards {
    enum Stack {
        case column, pile, extra
    }
    
    let cards: [Card]
    let stackType: Stack
    let stackIndex: Int
    let cardIndex: Int
    var position: CGPoint
}

//4 ячейки, для складирования карт от туза
//основная колода, с возможностью переворачивать карты
//7 колоннок с картами начинающимися с лева на право с увеличением на 1

typealias Deck = [Card]

extension Deck {
    static func initial() -> Self {
        Card.Suit.allCases.compactMap { suit in
            Card.Rank.allCases.compactMap { Card(suit: suit, rank: $0) }//.shuffled()
        }.flatMap { $0 }//.shuffled()
    }
}
