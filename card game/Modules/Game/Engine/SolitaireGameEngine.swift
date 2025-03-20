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
    private var needsRefreshZIndexesColumn: Int?
    
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
                    position: layout.pointForInitState(for: column, row: row),
                    zIndex: row,
                    error: 0
                )
            }
        }.flatMap { $0 })
    }
    
    // MARK: Actions
    
    func moveCardIfPossible(index: Int, for state: SolitaireState) -> SolitaireState? {
        let (realIndex, card) = realCardAndIndex(index: index, for: state)
        
        guard let to = findColumtTo(for: card, for: state) else { return nil }

        var newState = state
        move(index: realIndex, to: to, for: &newState)
        return newState
    }

    func move(index: Int, to: Int, for state: SolitaireState) -> SolitaireState? {
        guard  canStack(index: index, to: to, for: state) else { return nil }
        
        let (realIndex, _) = realCardAndIndex(index: index, for: state)
        
        var newState = state
        move(index: realIndex, to: to, for: &newState)
        return newState
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

        for fStacksInd in (Int.fStacksMinInd...Int.fStacksMaxInd) {
            let map = getMap(for: state)
            if let cardInd = map[fStacksInd]?.last, let next = state.cards[cardInd].card.next {
                for stackInd in (0...Int.tStacksMaxInd) where !map[stackInd]!.isEmpty {
                    let stackCardInd = map[stackInd]!.last!
                    if state.cards[stackCardInd].card == next {
                        move(index: stackCardInd, to: fStacksInd, for: &newState)
                    }
                }
                for stackInd in (Int.stockInd...Int.talonInd) where !map[stackInd]!.isEmpty {
                    for stackCardInd in map[stackInd]! {
                        if state.cards[stackCardInd].card == next {
                            move(index: stackCardInd, to: fStacksInd, for: &newState)
                        }
                    }
                }
            }
        }
        return newState
    }
    
    func updateColumnZIndexAfter(column: Int) {
        needsRefreshZIndexesColumn = column
    }
    
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
        
    private func move(index: Int, to: Int, for state: inout SolitaireState) {
        var map = getMap(for: state)
        
        handleNeedsRefreshZIndexesColumn(map: map, state: &state)
        
        let card = state.cards[index]
        let column = card.column
        
        if to == .talonInd, let topCardIndex = map[.stockInd]!.first {
            state.cards[topCardIndex].column = .talonInd
            state.cards[topCardIndex].row = map[.talonInd]!.count
            state.cards[topCardIndex].isOpen = true

            map[.stockInd]!.removeFirst()
            map[.talonInd]!.append(topCardIndex)
            
        } else {
            let indexes: [Int]
            if card.column > .tStacksMaxInd { // fix for auto
                indexes = [index]
            } else {
                indexes = Array(map[column]![card.row..<map[column]!.count])
            }

            let zIndex = self.zIndex(to: to, state: state)
            
            needsRefreshZIndexesColumn = to
            indexes.indices.forEach { tIndex in
                let mIndex = indexes[tIndex]
                let row = map[to]!.count
                state.cards[mIndex].column = to
                state.cards[mIndex].row = row
                state.cards[mIndex].position = position(index: mIndex, column: to, row: row, state: state)
                state.cards[mIndex].zIndex = zIndex + tIndex
                state.cards[mIndex].isOpen = true // fix for auto
                
                map[column]!.removeAll(where: { $0 == mIndex })
                map[to]!.append(mIndex)
                tempMap = map
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
                state.cards[talonIndex].position = layout.talonPoint(row: row)
                state.cards[talonIndex].zIndex = state.cards[talonIndex].row
            }
        } else if column <= .tStacksMaxInd, let lastRowIndex = map[column]!.last { // open card
            state.cards[lastRowIndex].isOpen = true
        }

        tempMap = map
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
        let card = state.cards[index]
        let map = getMap(for: state)
        let numberOfCards = map[column]!.count - state.cards[index].row
        
        if to <= .tStacksMaxInd {
            return canStackOnTStack(
                card: card,
                to: to,
                map: map,
                for: state
            )
        } else if to >= .fStacksMinInd && to <= .fStacksMaxInd && numberOfCards == .oneCard {
            return canStackOnFStack(
                card: card,
                to: to,
                map: map,
                for: state
            )
        } else {
            return false
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
        
    private func zIndex(to: Int, state: SolitaireState) -> Int {
        let map = getMap(for: state)
        
        let tStacksMaxZIndex = (0...Int.tStacksMaxInd).compactMap { map[$0]!.count }.max() ?? 0
        
        if to <= .tStacksMaxInd {
            return tStacksMaxZIndex
        } else {
            return max(map[to]!.count + 1, tStacksMaxZIndex)
        }
    }
    
    private func position(index: Int, column: Int, row: Int, state: SolitaireState) -> CGPoint {
        if row == 0 || column > .tStacksMaxInd {
            return layout.point(for: column, row: row)
        } else {
            let map = getMap(for: state)
            let pIndex = map[column]![row - 1]
            let offsetY = state.cards[pIndex].isOpen ? layout.offsetY : layout.offsetY / 2
            return CGPoint(
                x: state.cards[pIndex].position.x,
                y: state.cards[pIndex].position.y + offsetY
            )
        }
    }
    
    private func handleNeedsRefreshZIndexesColumn(map: [Int:[Int]], state: inout SolitaireState) {
        if let needsRefreshZIndexesColumn {
            map[needsRefreshZIndexesColumn]!.indices.forEach { tIndex in
                let mIndex = map[needsRefreshZIndexesColumn]![tIndex]
                state.cards[mIndex].zIndex = tIndex
            }
            
            self.needsRefreshZIndexesColumn = nil
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

// автосбор, херня

// игра недели
// получить
// юзер создать и сохранить
// получить таблицу
// закинуть результат на сервер
// сервер
