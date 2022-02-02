//
//  GameTableViewModel.swift
//  Solitaire
//
//  Created by v.s.zhukov on 21.01.2022.
//

import SwiftUI

final class GameTableViewModel: ObservableObject {
    @Published var game: Game
    
    @Published var movingCards: MovingCards?
    
    @Published var hasMoves: Bool = true
    @Published var gameOver: Bool = false
    
    private var moves: [Game] = []
    
    init(with game: Game = Game()) {
        self.game = game
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
            if canStack(card: cards.first!, onCard: game.piles[columnEndIndex].last, isColumn: false) {
                cards.indices.forEach { cards[$0].isHide = false }
                game.piles[columnEndIndex].append(contentsOf: cards)
                
                removeFromStartStack(movingCards: movingCards)
                checkForGameOver()
            } else {
                backCardsToStartStack()
            }
        } else {
            let columnEndIndex = Int(position.x / (UIScreen.main.bounds.width / 7))

            if canStack(card: cards.first!, onCard: game.columns[columnEndIndex].last, isColumn: true) {
                cards.indices.forEach { cards[$0].isHide = false }
                game.columns[columnEndIndex].append(contentsOf: cards)
                
                removeFromStartStack(movingCards: movingCards)
                checkForGameOver()
            } else {
                backCardsToStartStack()
            }
        }
        self.movingCards = nil
    }
    
    func onTap(card: Card) {
        guard let movingCards = findMovingCards(by: card) else { return }

        if movingCards.cards.count == 1 {
            for index in game.piles.indices {
                if canStack(card: movingCards.cards.first!, onCard: game.piles[index].last, isColumn: false) {
                    withAnimation {
                        game.piles[index].append(contentsOf: movingCards.cards)
                        removeFromStartStack(movingCards: movingCards)
                        checkForGameOver()
                    }
                    return
                }
            }
        }
        
        for index in game.columns.indices {
            if canStack(card: movingCards.cards.first!, onCard: game.columns[index].last, isColumn: true) {
                withAnimation {
                    game.columns[index].append(contentsOf: movingCards.cards)
                    removeFromStartStack(movingCards: movingCards)
                    checkForGameOver()
                }
                return
            }
        }
    }
    
    func openCard() {
        if let card = game.extraCards.popLast() {
            if game.openCards.count < 3 {
                game.openCards.insert(card, at: 0)
            } else {
                game.showedCards.append(game.openCards.popLast()!)
                game.openCards.insert(card, at: 0)
            }
        } else {
            game.extraCards = game.showedCards + game.openCards
            game.showedCards = []
            game.openCards = []
        }
    }
    
    private func findMovingCards(by card: Card) -> MovingCards? {
        if let columnIndex = game.columns.firstIndex(where: { $0.contains(card) }) {
            guard let cardIndex = game.columns[columnIndex].firstIndex(where: { $0.id == card.id }) else { return nil }
                    
            let cards = Array(game.columns[columnIndex][cardIndex..<game.columns[columnIndex].count])
            
            return MovingCards(cards: cards, stackType: .column, stackIndex: columnIndex, cardIndex: cardIndex, position: .zero)
        } else if game.openCards.contains(card) {
            guard game.openCards.first?.id == card.id else { return nil }
                        
            return MovingCards(cards: [card], stackType: .extra, stackIndex: 0, cardIndex: 0, position: .zero)
        } else if let pileIndex = game.piles.firstIndex(where: { $0.contains(card)}) {
            guard let cardIndex = game.piles[pileIndex].firstIndex(where: { $0.id == card.id }) else { return nil }
            
            let cards = Array(game.piles[pileIndex][cardIndex..<game.piles[pileIndex].count])
            
            return MovingCards(cards: cards, stackType: .pile, stackIndex: pileIndex, cardIndex: cardIndex, position: .zero)
        }
        return nil
    }
    
    private func hide(movingCards: MovingCards?) {
        guard let movingCards = movingCards else { return }
        switch movingCards.stackType {
        case .pile:
            (movingCards.cardIndex..<game.piles[movingCards.stackIndex].count).forEach {
                game.piles[movingCards.stackIndex][$0].isHide = true
            }
        case .extra:
            game.openCards[0].isHide = true
        case .column:
            (movingCards.cardIndex..<game.columns[movingCards.stackIndex].count).forEach {
                game.columns[movingCards.stackIndex][$0].isHide = true
            }
        }
    }
        
    private func removeFromStartStack(movingCards: MovingCards) {
        switch movingCards.stackType {
        case .pile:
            game.piles[movingCards.stackIndex].removeLast()
        case .extra:
            game.openCards.removeFirst()
        case .column:
            game.columns[movingCards.stackIndex].removeSubrange(movingCards.cardIndex..<game.columns[movingCards.stackIndex].count)

            let lastCardIndex = game.columns[movingCards.stackIndex].count - 1
            if lastCardIndex >= 0, !game.columns[movingCards.stackIndex].isEmpty {
                game.columns[movingCards.stackIndex][lastCardIndex].isOpen = true
            }
        }
    }
        
    private func backCardsToStartStack() {
        guard let movingCards = movingCards else { return }
        switch movingCards.stackType {
        case .pile:
            game.piles[movingCards.stackIndex][game.piles[movingCards.stackIndex].count - 1].isHide = false
        case .extra:
            game.openCards[0].isHide = false
        case .column:
            (movingCards.cardIndex..<game.columns[movingCards.stackIndex].count).forEach {
                game.columns[movingCards.stackIndex][$0].isHide = false
            }
        }
    }
    
    private func checkForMoves() {
        //?
    }
    
    private func checkForGameOver() {
        if game.piles.compactMap({ $0.count }).reduce(0, +) == 56 {
            gameOver = true
        }
    }
    
    private func canStack(card: Card, onCard: Card?, isColumn: Bool) -> Bool {
        if isColumn {
            if let _card = onCard {
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
        } else {
            if let _card = onCard {
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

//struct Extra {
//    var cards: [Card]
//    var showedCards: [Card] = []
//    var openCards: [Card] = []
//}

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
