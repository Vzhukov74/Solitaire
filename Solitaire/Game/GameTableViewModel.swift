//
//  GameTableViewModel.swift
//  Solitaire
//
//  Created by v.s.zhukov on 21.01.2022.
//

import SwiftUI

struct CardViewModel {
    var card: Card
    var column: Int
    var row: Int
    var position: CGPoint
    var moving: CGPoint?
    var zIndex: Int = 0
}

final class GameTableViewModel: ObservableObject {
    @Published var game: Game
    
    //@Published var movingCards: MovingCards?
    
    @Published var hasMoves: Bool = true
    @Published var gameOver: Bool = false
    
    // индексы 0-6 кучки, 7 - доп карты, 8-11 бита
    @Published var cards: [[CardViewModel]] = []
    
    private var moves: [Game] = [] // ??
    
    // MARK: piles coordinate
    let cardSize: CGSize
    let pile1: CGPoint
    let pile2: CGPoint
    let pile3: CGPoint
    let pile4: CGPoint
    let extra: CGPoint
    let columns: [CGPoint]
    let offsetY: CGFloat
    
    init(with game: Game = Game()) {
        self.game = game
        
        let spacing: CGFloat = 8
        let width = (UIScreen.main.bounds.width - spacing * 8) / 7
        let height = width * 1.5

        cardSize = CGSize(width: width, height: height)
        pile1 = CGPoint(x: width / 2, y: height / 2)
        pile2 = CGPoint(x: pile1.x + width + spacing, y: height / 2)
        pile3 = CGPoint(x: pile2.x + width + spacing, y: height / 2)
        pile4 = CGPoint(x: pile3.x + width + spacing, y: height / 2)
        
        extra = CGPoint(x: UIScreen.main.bounds.width - width / 2 - 2 * spacing, y: height / 2)
        
        let indexes: [Int] = Array(0...7)
        
        func column(for index: CGFloat) -> CGPoint {
            CGPoint(
                x: width / 2 + index * width + index * spacing,
                y: height + height / 2 + 2 * spacing
            )
        }
        
        columns = indexes.map { CGFloat($0) }.compactMap {
            column(for: $0)
        }  
        
        offsetY = height / 3.3
        
        var cards: [[CardViewModel]] = []
        
        game.columns.indices.forEach { columnIndex in
            var column: [CardViewModel] = []
            game.columns[columnIndex].indices.forEach { cardIndex in
                column.append(CardViewModel(
                    card: game.columns[columnIndex][cardIndex],
                    column: columnIndex,
                    row: cardIndex,
                    position: CGPoint(
                        x: columns[columnIndex].x,
                        y: columns[columnIndex].y + offsetY * CGFloat(cardIndex)
                    )
                ))
            }
            cards.append(column)
        }
        
        var column: [CardViewModel] = []
        game.extraCards.forEach {
            column.append(CardViewModel(
                card: $0,
                column: 99,
                row: 0,
                position: CGPoint(
                    x: extra.x,
                    y: extra.y
                )
            ))
        }
        cards.append(column)
        
        cards.append([]) //pile1
        cards.append([]) //pile2
        cards.append([]) //pile3
        cards.append([]) //pile4
        
        self.cards = cards
    }
    
    // MARK: target column
    
    func targetColumn(_ column: Int, _ row: Int, at position: CGPoint) -> Int? {
        guard cards[column][row].card.isOpen else { return nil }
        
        let columnEndIndex = Int(position.x / (UIScreen.main.bounds.width / 7))

        if position.y < (UIScreen.main.bounds.width / 7) * 1.5, columnEndIndex <= 3 {
            return nil
        } else {
            let targetColumn = Int(position.x / (UIScreen.main.bounds.width / 7))
            if let otherCard = cards[targetColumn].last,
               canStack(card: cards[column][row].card, onCard: otherCard.card, isColumn: true) {

                return targetColumn
            } else {
                return nil
            }
        }
    }
    
    func targetColumnByTap(_ column: Int, _ row: Int) -> Int? {
        guard cards[column][row].card.isOpen else { return nil }
                
        let card = cards[column][row].card

        for index in cards.indices {
            let isColumn = index < 7
            
            if index != 7,
               canStack(card: card, onCard: cards[index].last?.card, isColumn: isColumn) {
                return index
            }
        }
        
        return nil
    }
    
    // MARK: moving cards

    func movingCards(_ column: Int, _ row: Int, at position: CGPoint) {
        guard cards[column][row].card.isOpen else { return }
                
        let count = cards[column].count - row
        (0..<count).forEach { indexOffset in
            cards[column][row + indexOffset].moving = CGPoint(
                x: position.x,
                y: position.y + CGFloat(indexOffset) * offsetY
            )
            cards[column][row + indexOffset].zIndex = 1
        }
    }
    
    // MARK: moving finish
    
    func backCardsToStartStack(_ column: Int, _ row: Int) {
        let count = cards[column].count - row
        (0..<count).forEach { indexOffset in
            cards[column][row + indexOffset].moving = nil
            cards[column][row + indexOffset].zIndex = 0
        }
    }
    
    func moveCards(_ column: Int, _ row: Int, _ targetColumn: Int) {
        let endPosition: CGPoint!
        
        if targetColumn < 7 {
            endPosition = cards[targetColumn].last!.position
        } else if targetColumn == 8 {
            endPosition = pile1
        } else if targetColumn == 9 {
            endPosition = pile2
        } else if targetColumn == 10 {
            endPosition = pile3
        } else if targetColumn == 11 {
            endPosition = pile4
        } else {
            fatalError("wrong target column")
        }
        
        let offset = targetColumn < 7 ? offsetY : 0
        
        for index in (row..<cards[column].count) {
            cards[column][index].position = CGPoint(
                x: endPosition.x,
                y: endPosition.y + offset * CGFloat(index - row + 1)
            )
            cards[column][index].moving = nil
            cards[column][index].zIndex = 1
        }
        
        if row > 0 {
            cards[column][row - 1].card.isOpen = true
        }
    }
    
    func moveCardsCompletion(_ column: Int, _ row: Int, _ targetColumn: Int) {
        guard targetColumn != 7 else { fatalError("wrong target column") }
        
        let count = cards[column].count - row
        
        var movingCardsVM: [CardViewModel] = []
        for _ in (0..<(count)) {
            movingCardsVM.append(cards[column].removeLast())
        }
        cards[targetColumn].append(contentsOf: movingCardsVM.reversed())
    }
        
//    func openCard() {
//        if let card = game.extraCards.popLast() {
//            if game.openCards.count < 3 {
//                game.openCards.insert(card, at: 0)
//            } else {
//                game.showedCards.append(game.openCards.popLast()!)
//                game.openCards.insert(card, at: 0)
//            }
//        } else {
//            game.extraCards = game.showedCards + game.openCards
//            game.showedCards = []
//            game.openCards = []
//        }
//    }
//
//    private func hide(movingCards: MovingCards?) {
//        guard let movingCards = movingCards else { return }
//        switch movingCards.stackType {
//        case .pile:
//            (movingCards.cardIndex..<game.piles[movingCards.stackIndex].count).forEach {
//                game.piles[movingCards.stackIndex][$0].isHide = true
//            }
//        case .extra:
//            game.openCards[0].isHide = true
//        case .column:
//            (movingCards.cardIndex..<game.columns[movingCards.stackIndex].count).forEach {
//                game.columns[movingCards.stackIndex][$0].isHide = true
//            }
//        }
//    }
//        
//    private func removeFromStartStack(movingCards: MovingCards) {
//        switch movingCards.stackType {
//        case .pile:
//            game.piles[movingCards.stackIndex].removeLast()
//        case .extra:
//            game.openCards.removeFirst()
//        case .column:
//            game.columns[movingCards.stackIndex].removeSubrange(movingCards.cardIndex..<game.columns[movingCards.stackIndex].count)
//
//            let lastCardIndex = game.columns[movingCards.stackIndex].count - 1
//            if lastCardIndex >= 0, !game.columns[movingCards.stackIndex].isEmpty {
//                game.columns[movingCards.stackIndex][lastCardIndex].isOpen = true
//            }
//        }
//    }
//        
//    private func backCardsToStartStack() {
//        guard let movingCards = movingCards else { return }
//        switch movingCards.stackType {
//        case .pile:
//            game.piles[movingCards.stackIndex][game.piles[movingCards.stackIndex].count - 1].isHide = false
//        case .extra:
//            game.openCards[0].isHide = false
//        case .column:
//            (movingCards.cardIndex..<game.columns[movingCards.stackIndex].count).forEach {
//                game.columns[movingCards.stackIndex][$0].isHide = false
//            }
//        }
//    }
//    
//    private func checkForMoves() {
//        //?
//    }
    
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

//struct Column {
//    var cards: [Card]
//    
//    func canStack(card: Card) -> Bool {
//        if let _card = cards.last {
//            if ((_card.suit == .clubs || _card.suit == .spades) && (card.suit == .hearts || card.suit == .diamonds)) ||
//                ((_card.suit == .hearts || _card.suit == .diamonds) && (card.suit == .clubs || card.suit == .spades)) {
//                if _card.rank.rawValue == card.rank.rawValue + 1 {
//                    return true
//                } else {
//                    return false
//                }
//            } else {
//                return false
//            }
//        } else if card.rank == .king {
//            return true
//        } else {
//            return false
//        }
//    }
//}
//
//struct Pile {
//    var cards: [Card] = []
//    
//    func canStack(card: Card) -> Bool {
//        if let _card = cards.last {
//            if _card.suit == card.suit {
//                if _card.rank.rawValue == card.rank.rawValue - 1 {
//                    return true
//                } else {
//                    return false
//                }
//            } else {
//                return false
//            }
//        } else if card.rank == .ace {
//            return true
//        } else {
//            return false
//        }
//    }
//}

//struct Extra {
//    var cards: [Card]
//    var showedCards: [Card] = []
//    var openCards: [Card] = []
//}

//struct MovingCards {
//    enum Stack {
//        case column, pile, extra
//    }
//    
//    let cards: [Card]
//    let stackType: Stack
//    let stackIndex: Int
//    let cardIndex: Int
//    var position: CGPoint
//}
