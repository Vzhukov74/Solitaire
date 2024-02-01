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
    @Published var cards: [CardViewModel] = []
    
    private var cardsIndexes: [Int: [Int]] = [:]
    
    private var moves: [Game] = [] // ??
    
    // MARK: piles coordinate
    let cardSize: CGSize
    let piles: [CGPoint]
    let columns: [CGPoint]
    let extra: CGPoint
    let extraPile: CGPoint
    let offsetY: CGFloat
    
    init(with game: Game = Game()) {
        self.game = game
        
        let spacing: CGFloat = 8
        let width = (UIScreen.main.bounds.width - spacing * 8) / 7
        let height = width * 1.5

        cardSize = CGSize(width: width, height: height)
        piles = [
            CGPoint(x: width / 2, y: height / 2),
            CGPoint(x: width / 2 + width + spacing, y: height / 2),
            CGPoint(x: width / 2 + width + spacing + width + spacing, y: height / 2),
            CGPoint(x: width / 2 + width + spacing + width + spacing + width + spacing, y: height / 2),
        ]
        
        extra = CGPoint(x: UIScreen.main.bounds.width - width / 2 - 2 * spacing, y: height / 2)
        extraPile = CGPoint(x: extra.x - width - spacing, y: extra.y)
        
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
        
        var cards: [CardViewModel] = []
        
        for index in (0...12) {
            cardsIndexes[index] = []
        }

        var cardIndexR: Int = 0
        
        game.columns.indices.forEach { columnIndex in
            game.columns[columnIndex].indices.forEach { cardIndex in
                let card = CardViewModel(
                    card: game.columns[columnIndex][cardIndex],
                    column: columnIndex,
                    row: cardIndex,
                    position: CGPoint(
                        x: columns[columnIndex].x,
                        y: columns[columnIndex].y + offsetY * CGFloat(cardIndex)
                    )
                )
                cards.append(card)
                cardsIndexes[columnIndex + 4]?.append(cardIndexR)
                cardIndexR += 1
            }
        }
        
        game.extraCards.forEach {
            cards.append(CardViewModel(
                card: $0,
                column: 99,
                row: 0,
                position: CGPoint(
                    x: extra.x,
                    y: extra.y
                )
            ))
            cardsIndexes[11]?.append(cardIndexR)
            cardIndexR += 1
        }
                
        self.cards = cards
    }
    
    // MARK: target column
    
    func targetColumn(_ index: Int, at position: CGPoint) -> (Int, Int)? {
        guard cards[index].card.isOpen else { return nil }
        
        guard let cardColumn = cardsIndexes.first(where: { $0.value.contains(index) })?.key else { return nil }
        
        let toColumn = Int(position.x / (UIScreen.main.bounds.width / 7))

        if position.y < (UIScreen.main.bounds.width / 7) * 1.5, toColumn <= 3 {
            return nil
        } else {
            var onCard: Card?
            if let targetCardIndex = cardsIndexes[toColumn + 4]?.last {
                onCard = cards[targetCardIndex].card
            }
                        
            let card = cards[index].card
            if canStack(card: card, onCard: onCard, isColumn: true) {
                return (cardColumn, toColumn + 4)
            } else {
                return nil
            }
        }
    }
    
    func targetColumnByTap(_ index: Int) -> (Int, Int)? {
        guard let cardColumn = cardsIndexes.first(where: { $0.value.contains(index) })?.key else { return nil }
        
        guard cards[index].card.isOpen || cardColumn > 10 else { return nil }
        
        if cardColumn == 11 {
            return (cardColumn, 12)
        }

        let card = cards[index].card

        for index in (0...12) where index != cardColumn {
            var onCard: Card?
            if let targetCardIndex = cardsIndexes[index]?.last {
                onCard = cards[targetCardIndex].card
            }
            
            let isColumn = index > 3 && index < 11
            
            if canStack(card: card, onCard: onCard, isColumn: isColumn) {
                return (cardColumn, index)
            }
        }
        
        return nil
    }
    
    func refreshExtraPile() {
//        guard cards[11].isEmpty else { return }
//        
//        for index in cards[12].indices {
//            cards[12][index].moving = extra
//            cards[12][index].card.isOpen = false
//        }
    }
    
    func moveCardsToExtraPile() {
//        cards[11] = cards[12]
//        cards[12].removeAll()
    }
    
    func restart() {
        
    }
    
    // MARK: moving cards

    func movingCards(_ index: Int, at position: CGPoint) {
        guard cards[index].card.isOpen else { return }
        guard let cardColumn = cardsIndexes.first(where: { $0.value.contains(index) })?.key else { return }
        let row = cardsIndexes[cardColumn]!.firstIndex(of: index)!

        let count = cardsIndexes[cardColumn]!.count
        (row..<count).forEach { cardIndex in
            cards[cardsIndexes[cardColumn]![cardIndex]].moving = CGPoint(
                x: position.x,
                y: position.y + CGFloat(count - 1 - cardIndex) * offsetY
            )
            cards[cardsIndexes[cardColumn]![cardIndex]].zIndex = 1
        }
    }
    
    // MARK: moving finish
    
    func backCardsToStartStack(_ index: Int) {
        guard cards[index].card.isOpen else { return }
        guard let cardColumn = cardsIndexes.first(where: { $0.value.contains(index) })?.key else { return }
        let row = cardsIndexes[cardColumn]!.firstIndex(of: index)!

        let count = cardsIndexes[cardColumn]!.count
        (row..<count).forEach { cardIndex in
            cards[cardsIndexes[cardColumn]![cardIndex]].moving = nil
            cards[cardsIndexes[cardColumn]![cardIndex]].zIndex = 0
        }
    }
    
    func moveCards(_ index: Int, _ fromColumn: Int, _ toColumn: Int) {
        let endPosition: CGPoint!
        
        if toColumn < 4 {
            endPosition = piles[toColumn]
        } else if toColumn < 11 {
            if let toColumnLastIndex = cardsIndexes[toColumn]?.last {
                endPosition = cards[toColumnLastIndex].position
            } else {
                endPosition = columns[toColumn - 4]
            }
        } else if toColumn == 12 {
            endPosition = extraPile
        } else {
            fatalError("wrong target column")
        }
        
        if toColumn == 12 {
//            cards[column][row].position = endPosition
//            cards[column][row].card.isOpen = true
//            cards[column][row].moving = nil
//            cards[column][row].zIndex = 1
//            
//            for index in cards[targetColumn].indices.reversed() {
//                let factor = cards[targetColumn].count - index <= 2 ? cards[targetColumn].count - index : 2
//                cards[targetColumn][index].position = CGPoint(
//                    x: endPosition.x - offsetY * CGFloat(factor),
//                    y: endPosition.y
//                )
//            }
        } else {
            let offset = toColumn < 4 ? 0 : offsetY
            
            let row = cardsIndexes[fromColumn]!.firstIndex(of: index)!
            let additional = cardsIndexes[toColumn]!.isEmpty ? 0 : 1
            
            for index in (row..<cardsIndexes[fromColumn]!.count) {
                let cardIndex = cardsIndexes[fromColumn]![index]
                cards[cardIndex].position = CGPoint(
                    x: endPosition.x,
                    y: endPosition.y + offset * CGFloat(index - row + additional)
                )
                cards[cardIndex].moving = nil
                cards[cardIndex].zIndex = 1
            }
            
            if row > 0 {
                let cardIndex = cardsIndexes[fromColumn]![row - 1]
                cards[cardIndex].card.isOpen = true
            }
        }
        
        moveCardsCompletion(index, fromColumn, toColumn)
    }
    
    func moveCardsCompletion(_ index: Int, _ fromColumn: Int, _ toColumn: Int) {
        let row = cardsIndexes[fromColumn]!.firstIndex(of: index)!
        let count = cardsIndexes[fromColumn]!.count - row
        
        var movingCardIndexes: [Int] = []
        for _ in (0..<(count)) {
            movingCardIndexes.append(cardsIndexes[fromColumn]!.removeLast())
        }
        cardsIndexes[toColumn]?.append(contentsOf: movingCardIndexes.reversed())
        
        checkForGameOver()
    }
            
    private func checkForGameOver() {
        gameOver = hasUnopenCards()
        print(gameOver)
    }
    
    private func hasUnopenCards() -> Bool {
        if let _ = cards.first(where: { !$0.card.isOpen }) {
            return false
        } else {
            return true
        }
    }
    
    private func canStack(card: Card, onCard: Card?, isColumn: Bool) -> Bool {
        if let onCard {
            return card.canStackOn(card: onCard, onPile: !isColumn)
        } else {
            return (isColumn && card.rank == .king) || (!isColumn && card.rank == .ace)
        }
    }
}
