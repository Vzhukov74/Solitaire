//
//  GameTableViewModel.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI

final class GameTableViewModel: ObservableObject {
    @Published var state: GameState
            
    private var isPauseBetweenMoves = false
    
    let layout: ICardLayout
    let feedbackService: IFeedbackService
    
    private let gameStore: IGamePersistentStore
    
    // timer
    private var timerTask: Task<Void, Never>?
    private var timerIsActive = false
    
    init(
        with game: Game?,
        gameStore: IGamePersistentStore,
        feedbackService: IFeedbackService,
        layout: ICardLayout
    ) {
        self.gameStore = gameStore
        self.feedbackService = feedbackService
        self.layout = layout
        
        if game != nil {
            self.state = GameState.state(from: game!)
            state.timeStr = game!.timeNumber.toTime
            state.pointsCoefficient = "x " + timeAndMovesCoefficient().toStr
        } else {
            self.state = GameState.new(with: layout)
        }
    }
        
    func newGame() {
        resetGame()
        state = GameState.new(with: layout)
    }
    
    func clear() {
        resetGame()
    }
    
    func onMainScreen() {
        gameStore.reset()
    }
    
    // MARK: public
    func cancelMove() {
        guard !state.gCardsHistory.isEmpty, !state.sCardsHistory.isEmpty  else { return }
        
        let previousGCards = state.gCardsHistory.popLast()!
        let previousSCards = state.sCardsHistory.popLast()!
        
        self.state.gCards = previousGCards
        self.state.sCards = previousSCards
        
        self.state.hasCancelMove = !state.gCardsHistory.isEmpty
    
        onMove()
    }
    
    func moveCardIfPossible(index: Int) {
        guard !onPause() else { return }
        guard let (column, row) = columnAndRowFor(card: index) else { return }
        
        // для фикса бага с 3 картами, сами выбираем 1 последнию карту из колоды
        if column == 12 { // в открытые дополнительные карты можно двигать всегда
            let realRow = state.sCards[12].count - 1
            moveCards(column: column, row: realRow, to: 11)
            feedbackService.swapCard()
            onMove()
            return
        } else if state.gCards[index].card.isOpen {
            if column == 11 {
                guard row == state.sCards[column].count - 1 else { return }
            }
            // ищем можем ли мы передвинуть куда либо карту, если нет то показываем ошибку
            guard let targetColumn = targetColumn(column: column, row: row) else {
                state.gCards[index].error += 1
                feedbackService.error()
                onMove()
                return
            }
            
            // нашли куда передвинуть, передвигаем
            moveCards(column: column, row: row, to: targetColumn)
            feedbackService.moveCard()
            onMove()
        }
    }
    
    // возвращаем открытые карты из дополнительной стопки обратно в стопку
    func refreshExtraCards() {
        guard !onPause() else { return }
        guard !state.sCards[11].isEmpty, state.sCards[12].isEmpty else { return }
                
        state.sCards[12] = state.sCards[11].reversed()
        state.sCards[11] = []
        
        for index in state.sCards[12].indices {
            state.sCards[12][index].card.isOpen = false
            state.gCards[state.sCards[12][index].index].card.isOpen = false
            state.gCards[state.sCards[12][index].index].position = layout.extra
            state.gCards[state.sCards[12][index].index].zIndex = index
        }
        onMove()
        feedbackService.swapCard()
    }
        
    func movingCards(_ index: Int, at position: CGPoint) {
        guard !isPauseBetweenMoves else { return }
        guard state.gCards[index].card.isOpen else { return }
        
        guard let (column, row) = columnAndRowFor(card: index) else { return }

        if column == 11 {
            guard row == state.sCards[column].count - 1 else { return }
        }
        
        // если карт больше чем 1, то делаем поправку на offsetY и Z индекс
        let count = state.sCards[column].count
        (row..<count).forEach { sCardIndex in
            let gCardIndex = state.sCards[column][sCardIndex].index
            state.gCards[gCardIndex].moving = CGPoint(
                x: position.x,
                y: position.y - CGFloat(row - sCardIndex) * layout.offsetY
            )
            state.gCards[gCardIndex].movingZIndex = 52 + 1 + sCardIndex
        }
    }
    
    func endMovingCards(_ index: Int, at position: CGPoint) {
        guard !isPauseBetweenMoves else { return }
        guard state.gCards[index].moving != nil else { return } // если не двигаем, то ничего не делаем
        
        onMove()
        
        guard let targetColumn = columnFor(position: position),
              let (column, row) = columnAndRowFor(card: index)
        else {
            backCardsToStartStack(index) // если не можем закинуть карты в стопку, возвращаем на место
            return
        }
        
        let card = state.gCards[index].card
        let isColumn = targetColumn < 7
        
        var onCard: Card? = nil
        if !state.sCards[targetColumn].isEmpty {
            let gCardsIndex = state.sCards[targetColumn][state.sCards[targetColumn].count - 1].index
            onCard = state.gCards[gCardsIndex].card
        }
        
        if canStack(card: card, onCard: onCard, isColumn: isColumn) {
            let count = state.sCards[column].count
            (row..<count).forEach { sCardIndex in
                let gCardIndex = state.sCards[column][sCardIndex].index
                state.gCards[gCardIndex].moving = nil
            }
            
            moveCards(column: column, row: row, to: targetColumn)
        } else {
            backCardsToStartStack(index)
        }
    }
    
    func save() {
        let game = state.game()
        gameStore.save(game)
    }
    
    // MARK: private
    
    private func resetGame() {
        timerIsActive = false
        timerTask?.cancel()
    }
    
    private func columnAndRowFor(card index: Int) -> (Int, Int)? {
        for column in state.sCards.indices {
            for row in state.sCards[column].indices {
                if state.sCards[column][row].card == state.gCards[index].card {
                    return (column, row)
                }
            }
        }
        return nil
    }
    
    private func columnFor(position: CGPoint) -> Int? {
        if position.y < layout.cardSize.height {
            let column = Int(position.x / (layout.size.width / 7))
            if column < 4 {
                return 7 + column
            } else {
                return nil
            }
        } else {
            return Int(position.x / (layout.size.width / 7))
        }
    }

    private func initCards(from deckShuffler: DeckShuffler) {
        var cards: [CardViewModel] = []
        let indexes = Array(0...12)
        var shadowIndex = 0
        indexes.forEach { index in
            if index >= 0, index < 7 {
                var shadowCardsColumn: [ShadowCardModel] = []
                for row in deckShuffler.columns[index].indices {
                    cards.append(
                        CardViewModel(
                            card: deckShuffler.columns[index][row],
                            position: CGPoint(
                                x: layout.columns[index].x,
                                y: layout.columns[index].y + (layout.offsetY / 2) * CGFloat(row)
                            )
                        )
                    )
                    shadowCardsColumn.append(ShadowCardModel(card: deckShuffler.columns[index][row], index: shadowIndex))
                    shadowIndex += 1
                }
                state.sCards.append(shadowCardsColumn)
            } else if index >= 7, index < 12 {
                cards.append(contentsOf: [])
                state.sCards.append([])
            } else if index == 12 {
                var shadowCardsColumn: [ShadowCardModel] = []
                for row in deckShuffler.extraCards.indices {
                    cards.append(
                        CardViewModel(
                            card: deckShuffler.extraCards[row],
                            position: layout.extra
                        )
                    )
                    shadowCardsColumn.append(ShadowCardModel(card: deckShuffler.extraCards[row], index: shadowIndex))
                    shadowIndex += 1
                }
                state.sCards.append(shadowCardsColumn)
            }
        }

        self.state.gCards = cards
    }
    
    private func applay(_ newGCards: [CardViewModel], _ newSCards: [[ShadowCardModel]], ifNeedAddPoints: Bool = false) {
        state.gCardsHistory.append(state.gCards)
        state.sCardsHistory.append(state.sCards)
        if state.gCardsHistory.count == 4 {
            state.gCardsHistory.remove(at: 0)
            state.sCardsHistory.remove(at: 0)
        }
        
        state.hasCancelMove = !state.gCardsHistory.isEmpty
        
        self.state.gCards = newGCards
        self.state.sCards = newSCards
        
        if ifNeedAddPoints {
            calculatePoints()
        }

        checkProgress()
    }
    
    private func moveCards(column: Int, row: Int, to: Int) {
        var newGCards = state.gCards
        var newSCards = state.sCards
        
        let movingCards: [ShadowCardModel] = Array(newSCards[column][row..<newSCards[column].count])
        
        let toRemove = newSCards[column].count - row
        (0..<toRemove).forEach { _ in _ = newSCards[column].popLast() }
        
        func position(to: Int, index: Int, start: CGPoint?) -> CGPoint {
            if to < 7 {
                var point = start ?? layout.columns[to]

                if start != nil { point.y = point.y + layout.offsetY }
                point.y = point.y + layout.offsetY * CGFloat(index)

                return point
            } else if to >= 7, to < 11 {
                return layout.piles[to - 7]
            } else {
                return .zero
            }
        }
        
        let toLastIndex = newSCards[to].last?.index
        let toStart: CGPoint? = toLastIndex == nil ? nil : newGCards[toLastIndex!].position
        
        var finalMovingCardsIndices: [Int] = []

        movingCards.indices.forEach { index in
            finalMovingCardsIndices.append(newSCards[to].count)

            var card = movingCards[index]
            card.card.isOpen = true
            newSCards[to].append(card)
            
            if to < 11 {
                newGCards[card.index].position = position(to: to, index: index, start: toStart)
                newGCards[card.index].moving = nil
            } else if to == 11 {
                newGCards[card.index].zIndex = 4
                newGCards[card.index].card.isOpen = true
            } else {
                fatalError("wrong to column")
            }
        }
        
        if column < 7, !newSCards[column].isEmpty {
            let lastCardIndex = newSCards[column].count - 1
            newSCards[column][lastCardIndex].card.isOpen = true
            newGCards[newSCards[column][lastCardIndex].index].card.isOpen = true
        }
        
        if column == 11 || to == 11, !newSCards[11].isEmpty {
            for rIndex in newSCards[11].indices.reversed() {
                let delta = newSCards[11].count - 1 - rIndex
                if delta < 5 {
                    newGCards[newSCards[11][rIndex].index].zIndex = 5 - delta
                    if delta < 3 {
                        newGCards[newSCards[11][rIndex].index].position = CGPoint(
                            x: layout.extraPile.x - layout.offsetY * CGFloat(delta),
                            y: layout.extraPile.y
                        )
                    }
                }
            }
        }
        
        for index in (0...10) {
            newSCards[index].indices.forEach {
                newGCards[newSCards[index][$0].index].zIndex = $0
            }
        }
        
        // ставим zIndex для перемещаемых карт как самый высокий,
        // что бы они были над всеми
        finalMovingCardsIndices.forEach { index in
            let gameCardIndex = newSCards[to][index].index
            newGCards[gameCardIndex].zIndex = 52 + 1 + index
        }
        
        // Если передвинули карту в конечную колоду или игровую
        let ifNeedAddPoints = to <= 10
        
        applay(newGCards, newSCards, ifNeedAddPoints: ifNeedAddPoints)
    }
        
    private func targetColumn(column: Int, row: Int) -> Int? {
        if column == 12 { return 11 }
        
        let numberOfCards = state.sCards[column].count - row
        
        // для прохода по столбцам в правильном порядке, сберва бита
        // потом столбцы с картами
        let indexes = [7, 8, 9, 10, 0, 1, 2, 3, 4, 5, 6]
        
        for index in indexes where index != column {
            let onCard = state.sCards[index].last?.card
            let isColumn = index < 7 // если индекс больше 6, значит это бита
            
            if isColumn {
                if canStack(card: state.sCards[column][row].card, onCard: onCard, isColumn: isColumn) {
                    return index
                }
            } else {
                if numberOfCards == 1 { // в биту можно положить 1 карту за раз
                    if canStack(card: state.sCards[column][row].card, onCard: onCard, isColumn: isColumn) {
                        return index
                    }
                }
            }
        }
        
        return nil
    }

    private func canStack(card: Card, onCard: Card?, isColumn: Bool) -> Bool {
        if let onCard {
            return card.canStackOn(card: onCard, onPile: !isColumn)
        } else {
            return (isColumn && card.rank == .king) || (!isColumn && card.rank == .ace)
        }
    }
    
    private func checkProgress() {
        for column in (0...6) {
            for row in state.sCards[column].indices {
                if !state.sCards[column][row].card.isOpen {
                    return
                }
            }
        }

        timerIsActive = false
        timerTask?.cancel()
        
        withAnimation { state.gameOver = true }
    }
    
    private func backCardsToStartStack(_ index: Int) {
        guard let (column, row) = columnAndRowFor(card: index) else { return }

        let count = state.sCards[column].count
        (row..<count).forEach { sCardIndex in
            let gCardIndex = state.sCards[column][sCardIndex].index
            state.gCards[gCardIndex].moving = nil
        }
    }

    private func onPause() -> Bool {
        if isPauseBetweenMoves {
            return isPauseBetweenMoves
        } else {
            isPauseBetweenMoves = true
            Task { @MainActor in
                try await Task.sleep(nanoseconds: 100_000_000)
                isPauseBetweenMoves = false
            }
            
            return false
        }
    }
    
    private func onMove() {
        state.movesNumber += 1
        state.pointsCoefficient = "x " + timeAndMovesCoefficient().toStr
                
        startTimerIfNeeded()

        save()
    }
    
    private func onTime() {
        state.timeNumber += 1
        state.pointsCoefficient = "x " + timeAndMovesCoefficient().toStr
        state.timeStr = state.timeNumber.toTime
                
        if timerIsActive { startTimer() }
    }
    
    private func startTimerIfNeeded() {
        guard !timerIsActive, !state.gameOver else { return }
        timerIsActive = true

        startTimer()
    }
    
    private func startTimer() {
        timerTask = Task { @MainActor in
            guard !Task.isCancelled else { return }
            try? await Task.sleep(for: .seconds(1))
            onTime()
        }
    }
    
    private func timeAndMovesCoefficient() -> Float {
        if state.movesNumber < 40 && state.timeNumber < 120 {
            return 3
        } else if state.movesNumber < 50 && state.timeNumber < 160 {
            return 2.8
        } else if state.movesNumber < 60 && state.timeNumber < 180 {
            return 2.6
        } else if state.movesNumber < 70 && state.timeNumber < 200 {
            return 2.4
        } else if state.movesNumber < 80 && state.timeNumber < 220 {
            return 2.2
        } else if state.movesNumber < 90 && state.timeNumber < 260 {
            return 2
        } else if state.movesNumber < 100 && state.timeNumber < 280 {
            return 1.6
        } else if state.movesNumber < 110 && state.timeNumber < 300 {
            return 1.4
        }

        return 1
    }
    
    private func calculatePoints() {
        let coefficient = timeAndMovesCoefficient()
        state.pointsNumber += Int(10 * coefficient)
    }
}

extension Int {
    var toTime: String {
        let mins = self / 60
        let secs = self % 60
        
        return secs > 9 ? "\(mins):\(secs)" : "\(mins):0\(secs)"
    }
}

extension Float {
    var toStr: String {
        String(format: "%.1f", self)
    }
}
