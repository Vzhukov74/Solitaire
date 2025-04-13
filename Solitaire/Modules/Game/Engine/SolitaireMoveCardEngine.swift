//
//  SolitaireMoveCardEngine.swift
//  card game
//
//  Created by Vladislav Zhukov on 11.03.2025.
//

import Foundation

final class SolitaireMoveCardEngine {
        
    let layout: ICardLayout
    
    private var movingState: [Int: CGPoint] = [:]
    
    init(layout: ICardLayout) {
        self.layout = layout
    }
    
    // MARK: move cards by hand
    func move(index: Int, to position: CGPoint, for state: SolitaireState) -> SolitaireState {
        let card = state.cards[index]
        
        let indexes: [Int]
        if card.column <= .tStacksMaxInd {
            let allCardsInColumn = state.cards.indices
                .filter { state.cards[$0].column == card.column }
                .sorted { state.cards[$0].row < state.cards[$1].row }
            indexes = Array(allCardsInColumn[card.row..<allCardsInColumn.count])
        } else {
            indexes = [index]
        }
                
        var newState = state
        
        if movingState.keys.isEmpty {
            indexes.indices.forEach { tIndex in
                let mIndex = indexes[tIndex]
                movingState[mIndex] = newState.cards[mIndex].position
            }
        }
        
        indexes.indices.forEach { tIndex in
            let mIndex = indexes[tIndex]
            
            newState.cards[mIndex].zIndex = .totalCards + tIndex
            newState.cards[mIndex].position = CGPoint(
                x: position.x,
                y: position.y + layout.offsetY * CGFloat(tIndex)
            )
        }

        return newState
    }
    
    func endMove(index: Int, to position: CGPoint, for state: SolitaireState) -> Int? {
        column(by: position)
    }
    
    func backMovingCard(for state: SolitaireState) -> SolitaireState {
        var newState = state
        
        movingState.keys.forEach { mIndex in
            newState.cards[mIndex].position = movingState[mIndex]!
        }
        
        return newState
    }
    
    func clear() {
        movingState.removeAll()
    }
    
    // MARK: private
    
    private func column(by position: CGPoint) -> Int? {
        if position.y < layout.cardSize.height {
            let column = Int(position.x / (layout.size.width / 7))
            if column < 4 {
                return .fStacksMinInd + column
            } else {
                return nil
            }
        } else {
            return Int(position.x / (layout.size.width / 7))
        }
    }
}
