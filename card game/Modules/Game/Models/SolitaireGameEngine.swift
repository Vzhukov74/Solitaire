//
//  SolitaireGameEngine.swift
//  card game
//
//  Created by Vladislav Zhukov on 01.03.2025.
//

import Foundation

final class SolitaireGameEngine {
    
    let layout: ICardLayout
    
    private var tempMap: [Int: [Int]]?
    
    init(layout: ICardLayout) {
        self.layout = layout
    }
    
    func vm(for deckShuffler: DeckShuffler = DeckShuffler()) -> SolitaireState {
        let stacks = deckShuffler.stacks

        return SolitaireState(cards: stacks.indices.compactMap { column in
            stacks[column].indices.compactMap { row in
                CardViewModel(
                    card: stacks[column][row],
                    isOpen: stacks[column].count - 1 == row && column != .stockInd ? true : false,
                    column: column,
                    row: row,
                    position: layout.point(for: column, row: row),
                    zIndex: row,
                    error: 0
                )
            }
        }.flatMap { $0 })
    }
    
    func moveCardIfPossible(index: Int, for state: SolitaireState) -> SolitaireState? {
        let (realIndex, card) = realCardAndIndex(index: index, for: state)
        
        guard let to = findColumtTo(for: card, for: state) else { return nil }

        return move(index: realIndex, to: to, for: state)
    }
    
    func returnTalonCardsBack(for state: SolitaireState) -> SolitaireState {
        var newState = state
        var map = getMap(for: state)
        
        let talon = map[.talonInd]!
        map[.talonInd] = []
        map[.stockInd] = talon
        
        talon.indices.forEach { index in
            newState.cards[talon[index]].column = .stockInd
            newState.cards[talon[index]].row = index
            newState.cards[talon[index]].position = layout.point(for: .stockInd, row: index)
            newState.cards[talon[index]].isOpen = false
        }

        tempMap = map
        return newState
    }
    
    // MARK: move cards by hand
    func move(index: Int, to position: CGPoint,for state: SolitaireState) -> SolitaireState {
        let (_, card) = realCardAndIndex(index: index, for: state)
        let map = getMap(for: state)
                
        var newState = state
        
        let indexes = Array(map[card.column]![card.row..<map[card.column]!.count])
        
        indexes.indices.forEach { iIndex in
            let mIndex = indexes[iIndex]
            newState.cards[mIndex].zIndex = .totalCards + indexes.count - iIndex
            let offsetY = layout.offsetY * CGFloat(iIndex)
            newState.cards[mIndex].position = CGPoint(
                x: position.x,
                y: position.y - offsetY
            )
        }

        return newState
    }
    
    func endMove(index: Int, to position: CGPoint, for state: SolitaireState) -> SolitaireState {
        let (realIndex, card) = realCardAndIndex(index: index, for: state)
        
        if let to = column(by: position), canStack(index: realIndex, to: to, for: state)  {
            return move(index: realIndex, to: to, for: state)
        } else {
            let map = getMap(for: state)
            
            var newState = state
            
            let indexes = Array(map[card.column]![card.row..<map[card.column]!.count])
            
            indexes.indices.forEach { mIndex in
                let row = newState.cards[mIndex].row
                let column = newState.cards[mIndex].column

                newState.cards[mIndex].position = layout.point(for: column, row: row)
                newState.cards[mIndex].zIndex = row
            }
            
            return newState
        }
    }
    
    // MARK: helpers
    func opendAllCards(for state: SolitaireState) -> Bool {
        let map = getMap(for: state)
        for tStacksInd in (0...Int.tStacksMaxInd) {
            for index in map[tStacksInd]! where !state.cards[index].isOpen {
                return false
            }
        }
        return true
    }
    
    func allCardsInFStacks(for state: SolitaireState) -> Bool {
        let map = getMap(for: state)
        for fStacksInd in (Int.fStacksMinInd...Int.fStacksMaxInd) {
            if map[fStacksInd]!.count != .totalCardsForOneSuit {
                return false
            }
        }
        return true
    }
    
    func auto(for state: SolitaireState) -> SolitaireState {
        var newState = state
        let map = getMap(for: state)
        
        for fStacksInd in (Int.fStacksMinInd...Int.fStacksMaxInd) {
            if let cardInd = map[fStacksInd]?.last, let next = state.cards[cardInd].card.next {
                for fStacksInd in (0..<Int.fStacksMinInd) where !map[fStacksInd]!.isEmpty {
                    let topCardInd = map[fStacksInd]!.last!
                    if state.cards[topCardInd].card == next {
                        return move(index: cardInd, to: fStacksInd, for: state)
                    }
                }
            }
        }
        return state
    }
    
    //MARK:
    func update(for state: SolitaireState) {
        _ = getMap(for: state, force: true)
    }
    
    // MARK: private
    private func realCardAndIndex(index: Int, for state: SolitaireState) -> (Int, CardViewModel) {
        var card = state.cards[index]
        var realIndex = index
        
        if state.cards[index].column == .talonInd {
            let map = getMap(for: state)
            if let rIndex = map[.talonInd]!.last {
                realIndex = rIndex
                card = state.cards[realIndex]
                
            }
        }
        
        return (realIndex, card)
    }

    private func findColumtTo(for card: CardViewModel, for state: SolitaireState) -> Int? {
        let column = card.column
        
        if column == .stockInd { return .talonInd }
        
        let map = getMap(for: state)
        
        // look in fStacks if is is only one card
        let numberOfCards = map[card.column]!.count - card.row
        if numberOfCards == .oneCard, column <= .fStacksMinInd {
            for to in (Int.fStacksMinInd...Int.fStacksMaxInd) where to != column {
                if canStackOnFStack(
                    card: card,
                    to: to,
                    map: map,
                    for: state
                ) {
                    return to
                }
            }
        }
        
        for to in (0...Int.tStacksMaxInd) where to != column {
            if canStackOnTStack(
                card: card,
                to: to,
                map: map,
                for: state
            ) {
                return to
            }
        }
        
        return nil
    }
        
    private func move(index: Int, to: Int, for state: SolitaireState) -> SolitaireState {
        var newState = state
        var map = getMap(for: state)
        
        let card = newState.cards[index]
        let column = card.column
        
        if to == .talonInd, let topCardIndex = map[.stockInd]!.first {
            newState.cards[topCardIndex].column = .talonInd
            newState.cards[topCardIndex].row = map[.talonInd]!.count
            newState.cards[topCardIndex].isOpen = true

            map[.stockInd]!.removeFirst()
            map[.talonInd]!.append(topCardIndex)
            
        } else {
            let indexes = Array(map[column]![card.row..<map[column]!.count])
            
            indexes.forEach { mIndex in
                let row = map[to]!.count
                newState.cards[mIndex].column = to
                newState.cards[mIndex].row = row
                newState.cards[mIndex].position = layout.point(for: to, row: row)
                newState.cards[mIndex].zIndex = row
                
                map[column]!.removeAll(where: { $0 == mIndex })
                map[to]!.append(mIndex)
            }
        }
        
        // update after moving
        if (column == .talonInd || to == .talonInd) && !map[.talonInd]!.isEmpty { // refresh talon
            let upperBound = map[.talonInd]!.count - 1
            var loverBound = map[.talonInd]!.count - 3
            loverBound = loverBound < 0 ? 0 : loverBound
            
            // update z index and position
            for boundIndex in (loverBound...upperBound)  {
                let talonIndex = map[.talonInd]![boundIndex]
                let row = map[.talonInd]!.count - boundIndex - 1
                newState.cards[talonIndex].position = layout.talonPoint(row: row)
                newState.cards[talonIndex].zIndex = newState.cards[talonIndex].row
            }
        } else if column <= .tStacksMaxInd, let lastRowIndex = map[column]!.last { // open card
            newState.cards[lastRowIndex].isOpen = true
        }

        tempMap = map
        return newState
    }
    
    private func getMap(for state: SolitaireState, force: Bool = false) -> [Int: [Int]] {
        if let tempMap, !force {
            return tempMap
        }
        
        var map: [Int: [Int]] = [:]
        (0...Int.fStacksMaxInd).forEach { map[$0] = [] }
        state.cards.indices.forEach {
            map[state.cards[$0].column]!.append($0)
        }
        
        map.keys.forEach { column in
            map[column] = map[column]!.sorted(by: { state.cards[$0].row < state.cards[$1].row })
        }
        
        tempMap = map
        return map
    }
    
    private func canStack(index: Int, to: Int, for state: SolitaireState) -> Bool {
        let column = state.cards[index].column
        let card = state.cards[index].card
        let map = getMap(for: state)
        let numberOfCards = map[column]!.count - state.cards[index].row
        let toStack = map[to]!
        let tStacks = to <= .tStacksMaxInd
        
        if toStack.isEmpty {
            if tStacks {
                return card.rank == .king
            } else {
                return card.rank == .ace && numberOfCards == 1
            }
        } else {
            return card.canStackOn(card: state.cards[toStack.last!].card, onPile: tStacks)
        }
        
    }
    
    private func canStackOnTStack(card: CardViewModel, to: Int, map: [Int: [Int]], for state: SolitaireState) -> Bool {
        let toStack = map[to]!
        
        if toStack.isEmpty {
            return card.card.rank == .king
        } else {
            return card.card.canStackOn(card: state.cards[toStack.last!].card, onPile: false)
        }
    }
    
    private func canStackOnFStack(card: CardViewModel, to: Int, map: [Int: [Int]], for state: SolitaireState) -> Bool {
        let toStack = map[to]!
        
        if toStack.isEmpty {
            return card.card.rank == .ace
        } else {
            return card.card.canStackOn(card: state.cards[toStack.last!].card, onPile: true)
        }
    }
    
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

extension Int {
    static let historySize: Int = 3
    
    static let oneCard: Int = 1
    static let totalCards: Int = 52
    static let totalCardsForOneSuit: Int = 13
    
    static let stockInd: Int = 7
    static let talonInd: Int = 8
    static let tStacksMaxInd: Int = 6
    static let fStacksMinInd: Int = 9
    static let fStacksMaxInd: Int = 12
}
