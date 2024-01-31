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
        
        var cards: [[CardViewModel]] = []
        
        cards.append([]) //pile1
        cards.append([]) //pile2
        cards.append([]) //pile3
        cards.append([]) //pile4

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
        cards.append([])
                
        self.cards = cards
    }
    
    // MARK: target column
    
    func targetColumn(_ column: Int, _ row: Int, at position: CGPoint) -> Int? {
        guard cards[column][row].card.isOpen else { return nil }
        
        let columnEndIndex = Int(position.x / (UIScreen.main.bounds.width / 7))

        if position.y < (UIScreen.main.bounds.width / 7) * 1.5, columnEndIndex <= 3 {
            return nil
        } else {
            let targetColumn = 4 + Int(position.x / (UIScreen.main.bounds.width / 7))
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
            let isColumn = index > 3 && index < 11
            
            if canStack(card: card, onCard: cards[index].last?.card, isColumn: isColumn) {
                return index
            }
        }
        
        if column == 11 {
            return 12
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
        
        if targetColumn < 4 {
            endPosition = piles[targetColumn]
        } else if targetColumn < 11 {
            endPosition = cards[targetColumn].last?.position ?? columns[targetColumn - 4]
        } else if targetColumn == 12 {
            endPosition = extraPile
        } else {
            fatalError("wrong target column")
        }
        
        if targetColumn == 12 {
            cards[column][row].position = endPosition
            cards[column][row].moving = nil
            cards[column][row].zIndex = 1
            
            for index in cards[targetColumn].indices.reversed() {
                let factor = cards[targetColumn].count - index <= 2 ? cards[targetColumn].count - index : 2
                cards[targetColumn][index].position = CGPoint(
                    x: endPosition.x - offsetY * CGFloat(factor),
                    y: endPosition.y
                )
            }
        } else {
            let offset = targetColumn < 4 ? 0 : offsetY
            let additional = cards[targetColumn].isEmpty ? 0 : 1
            
            for index in (row..<cards[column].count) {
                cards[column][index].position = CGPoint(
                    x: endPosition.x,
                    y: endPosition.y + offset * CGFloat(index - row + additional)
                )
                cards[column][index].moving = nil
                cards[column][index].zIndex = 1
            }
            
            if row > 0 {
                cards[column][row - 1].card.isOpen = true
            }
        }
    }
    
    func moveCardsCompletion(_ column: Int, _ row: Int, _ targetColumn: Int) {
        let count = cards[column].count - row
        
        var movingCardsVM: [CardViewModel] = []
        for _ in (0..<(count)) {
            movingCardsVM.append(cards[column].removeLast())
        }
        cards[targetColumn].append(contentsOf: movingCardsVM.reversed())
    }
            
    private func checkForGameOver() {
        if game.piles.compactMap({ $0.count }).reduce(0, +) == 56 {
            gameOver = true
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
