//
//  GameTableViewModel.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI

struct CardViewModel: Hashable, Codable {
    var card: Card

    var position: CGPoint
    var zIndex: Int = 0
    
    // for game
    var moving: CGPoint?
    var movingZIndex: Int = 0
    var error: Int = 0
        
    func hash(into hasher: inout Hasher) {
        hasher.combine(card)
        hasher.combine(position.x)
        hasher.combine(position.y)
    }
}

struct ShadowCardModel: Codable {
    var card: Card
    let index: Int
}

final class GameTableViewModel: ObservableObject {
    @Published var hasMoves: Bool = true
    @Published var hasCancelMove: Bool = false
    @Published var gameOver: Bool = false
        
    @Published var gCards: [CardViewModel] = []
    @Published var movesNumber: Int = 0
    @Published var pointsNumber: Int = 0
    @Published var timeStr: String = "0:00"
    @Published var pointsCoefficient: String = "x 3.0"
    
    private var sCards: [[ShadowCardModel]] = []
    
    private var gCardsHistory: [[CardViewModel]] = []
    private var sCardsHistory: [[[ShadowCardModel]]] = []
    
    private var isPauseBetweenMoves = false
    
    // MARK: piles coordinate
    private(set) var piles: [CGPoint] = []
    private(set) var columns: [CGPoint] = []
    private(set) var extra: CGPoint = .zero
    private(set) var extraPile: CGPoint = .zero
    private(set) var offsetY: CGFloat = 0
    
    private let size: CGSize
    
    let cardSize: CGSize

    private let feedbackService: IFeedbackService
    private let gameStore: IGamePersistentStore
    private var game: Game
    
    // timer
    private var timerTask: Task<Void, Never>?
    private var timerIsActive = false
    private var timeNumber: Int = 0
    
    init(
        with game: Game?,
        gameStore: IGamePersistentStore,
        feedbackService: IFeedbackService,
        size: CGSize,
        cardSize: CGSize
    ) {
        self.gameStore = gameStore
        self.feedbackService = feedbackService
        self.size = size
        self.cardSize = cardSize
        
        if game != nil {
            self.game = game!
            
            hasCancelMove = !game!.sCardsHistory.isEmpty
                
            gCards = game!.gCards
            sCards = game!.sCards
            movesNumber = game!.movesNumber
            pointsNumber = game!.points
            timeNumber = game!.timeNumber
            timeStr = timeNumber.toTime
            pointsCoefficient = "x " + timeAndMovesCoefficient().toStr

            gCardsHistory = game!.gCardsHistory
            sCardsHistory = game!.sCardsHistory
            
            self.calculateFrames(with: size)
            
        } else {
            self.game = Game()
            self.calculateFrames(with: size)
            self.initCards(from: DeckShuffler())
        }
    }
        
    func newGame() {
        resetGame()
        initCards(from: DeckShuffler())
    }
    
    func onMainScreen() {
        gameStore.reset()
    }
    
    // MARK: public
    func cancelMove() {
        guard !gCardsHistory.isEmpty, !sCardsHistory.isEmpty  else { return }
        
        let previousGCards = gCardsHistory.popLast()!
        let previousSCards = sCardsHistory.popLast()!
        
        self.gCards = previousGCards
        self.sCards = previousSCards
        
        game.gCards = previousGCards
        game.sCards = previousSCards
        game.gCardsHistory = gCardsHistory
        game.sCardsHistory = sCardsHistory
                
        self.hasCancelMove = !gCardsHistory.isEmpty
        
        onMove()
    }
    
    func moveCardIfPossible(index: Int) {
        guard !onPause() else { return }
        guard let (column, row) = columnAndRowFor(card: index) else { return }
        
        // для фикса бага с 3 картами, сами выбираем 1 последнию карту из колоды
        if column == 12 { // в открытые дополнительные карты можно двигать всегда
            let realRow = sCards[12].count - 1
            moveCards(column: column, row: realRow, to: 11)
            feedbackService.success()
            onMove()
            return
        } else if gCards[index].card.isOpen {
            if column == 11 {
                guard row == sCards[column].count - 1 else { return }
            }
            // ищем можем ли мы передвинуть куда либо карту, если нет то показываем ошибку
            guard let targetColumn = targetColumn(column: column, row: row) else {
                gCards[index].error += 1
                feedbackService.error()
                onMove()
                return
            }
            
            // нашли куда передвинуть, передвигаем
            moveCards(column: column, row: row, to: targetColumn)
            feedbackService.success()
            onMove()
        }
    }
    
    // возвращаем открытые карты из дополнительной стопки обратно в стопку
    func refreshExtraCards() {
        guard !onPause() else { return }
        guard !sCards[11].isEmpty, sCards[12].isEmpty else { return }
                
        sCards[12] = sCards[11].reversed()
        sCards[11] = []
        
        for index in sCards[12].indices {
            sCards[12][index].card.isOpen = false
            gCards[sCards[12][index].index].card.isOpen = false
            gCards[sCards[12][index].index].position = extra
            gCards[sCards[12][index].index].zIndex = index
        }
        onMove()
        feedbackService.success()
    }
        
    func movingCards(_ index: Int, at position: CGPoint) {
        guard !isPauseBetweenMoves else { return }
        guard gCards[index].card.isOpen else { return }
        
        guard let (column, row) = columnAndRowFor(card: index) else { return }

        if column == 11 {
            guard row == sCards[column].count - 1 else { return }
        }
        
        // если карт больше чем 1, то делаем поправку на offsetY и Z индекс
        let count = sCards[column].count
        (row..<count).forEach { sCardIndex in
            let gCardIndex = sCards[column][sCardIndex].index
            gCards[gCardIndex].moving = CGPoint(
                x: position.x,
                y: position.y - CGFloat(row - sCardIndex) * offsetY
            )
            gCards[gCardIndex].movingZIndex = 50 - (row - sCardIndex)
        }
    }
    
    func endMovingCards(_ index: Int, at position: CGPoint) {
        guard !isPauseBetweenMoves else { return }
        guard gCards[index].moving != nil else { return } // если не двигаем, то ничего не делаем
        
        onMove()
        
        guard let targetColumn = columnFor(position: position),
              let (column, row) = columnAndRowFor(card: index)
        else {
            backCardsToStartStack(index) // если не можем закинуть карты в стопку, возвращаем на место
            return
        }
        
        let card = gCards[index].card
        let isColumn = targetColumn < 7
        
        var onCard: Card? = nil
        if !sCards[targetColumn].isEmpty {
            let gCardsIndex = sCards[targetColumn][sCards[targetColumn].count - 1].index
            onCard = gCards[gCardsIndex].card
        }
        
        if canStack(card: card, onCard: onCard, isColumn: isColumn) {
            let count = sCards[column].count
            (row..<count).forEach { sCardIndex in
                let gCardIndex = sCards[column][sCardIndex].index
                gCards[gCardIndex].moving = nil
            }
            
            moveCards(column: column, row: row, to: targetColumn)
        } else {
            backCardsToStartStack(index)
        }
    }
    
    func save() {
        timerTask?.cancel()
        timerIsActive = false
        
        game.gCards = gCards
        game.sCards = sCards
        game.gCardsHistory = gCardsHistory
        game.sCardsHistory = sCardsHistory
        game.movesNumber = movesNumber
        game.points = pointsNumber
        game.timeNumber = timeNumber
        
        gameStore.save(game)
    }
    
    // MARK: private
    
    private func resetGame() {
        timerTask?.cancel()
        
        gCards = []
        sCards = []
        gCardsHistory = []
        sCardsHistory = []
        
        self.movesNumber = 0
        self.timeStr = "0:00"
        self.timeNumber = 0
        self.pointsNumber = 0
        self.timerIsActive = false
        self.pointsCoefficient = "x " + timeAndMovesCoefficient().toStr
        self.game = Game()
    }
    
    private func columnAndRowFor(card index: Int) -> (Int, Int)? {
        for column in sCards.indices {
            for row in sCards[column].indices {
                if sCards[column][row].card == gCards[index].card {
                    return (column, row)
                }
            }
        }
        return nil
    }
    
    private func columnFor(position: CGPoint) -> Int? {
        if position.y < cardSize.height {
            let column = Int(position.x / (size.width / 7))
            if column < 4 {
                return 7 + column
            } else {
                return nil
            }
        } else {
            return Int(position.x / (size.width / 7))
        }
    }
    
    private func calculateFrames(with size: CGSize) {
        let spacing: CGFloat = 8
        let width = cardSize.width
        let height = cardSize.height
    
        offsetY = height / 3.3
                
        func column(for index: CGFloat, heightDelta: CGFloat = 0) -> CGPoint {
            CGPoint(
                x: width / 2 + (width + spacing) * index,
                y: height / 2 + heightDelta
            )
        }
        
        var indexes: [Int] = Array(0...3)
        piles = indexes.map { CGFloat($0) }.compactMap { column(for: $0) }
        
        extra = CGPoint(x: size.width - width / 2 - 2 * spacing, y: height / 2)
        extraPile = CGPoint(x: extra.x - width - spacing, y: extra.y)
        
        indexes = Array(0...6)
        columns = indexes.map { CGFloat($0) }.compactMap { column(for: $0, heightDelta: height + 2 * spacing ) }
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
                                x: columns[index].x,
                                y: columns[index].y + (offsetY / 2) * CGFloat(row)
                            )
                        )
                    )
                    shadowCardsColumn.append(ShadowCardModel(card: deckShuffler.columns[index][row], index: shadowIndex))
                    shadowIndex += 1
                }
                sCards.append(shadowCardsColumn)
            } else if index >= 7, index < 12 {
                cards.append(contentsOf: [])
                sCards.append([])
            } else if index == 12 {
                var shadowCardsColumn: [ShadowCardModel] = []
                for row in deckShuffler.extraCards.indices {
                    cards.append(
                        CardViewModel(
                            card: deckShuffler.extraCards[row],
                            position: extra
                        )
                    )
                    shadowCardsColumn.append(ShadowCardModel(card: deckShuffler.extraCards[row], index: shadowIndex))
                    shadowIndex += 1
                }
                sCards.append(shadowCardsColumn)
            }
        }

        self.gCards = cards
    }
    
    private func applay(_ newGCards: [CardViewModel], _ newSCards: [[ShadowCardModel]]) {
        gCardsHistory.append(gCards)
        sCardsHistory.append(sCards)
        if gCardsHistory.count == 4 {
            gCardsHistory.remove(at: 0)
            sCardsHistory.remove(at: 0)
        }
        
        hasCancelMove = !gCardsHistory.isEmpty
        
        self.gCards = newGCards
        self.sCards = newSCards
        
        game.gCards = newGCards
        game.sCards = newSCards
        game.gCardsHistory = gCardsHistory
        game.sCardsHistory = sCardsHistory
        
        calculatePoints()
        checkProgress()
    }
    
    private func moveCards(column: Int, row: Int, to: Int) {
        var newGCards = gCards
        var newSCards = sCards
        
        let movingCards: [ShadowCardModel] = Array(newSCards[column][row..<newSCards[column].count])
        
        let toRemove = newSCards[column].count - row
        (0..<toRemove).forEach { _ in _ = newSCards[column].popLast() }
        
        func position(to: Int, index: Int, start: CGPoint?) -> CGPoint {
            if to < 7 {
                var point = start ?? columns[to]

                if start != nil { point.y = point.y + offsetY }
                point.y = point.y + offsetY * CGFloat(index)

                return point
            } else if to >= 7, to < 11 {
                return piles[to - 7]
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
                            x: extraPile.x - offsetY * CGFloat(delta),
                            y: extraPile.y
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
            newGCards[gameCardIndex].zIndex = 36 + 1 + index
        }
        
        applay(newGCards, newSCards)
    }
        
    private func targetColumn(column: Int, row: Int) -> Int? {
        if column == 12 { return 11 }
        
        let numberOfCards = sCards[column].count - row
        
        // для прохода по столбцам в правильном порядке, сберва бита
        // потом столбцы с картами
        let indexes = [7, 8, 9, 10, 0, 1, 2, 3, 4, 5, 6]
        
        for index in indexes where index != column {
            let onCard = sCards[index].last?.card
            let isColumn = index < 7 // если индекс больше 6, значит это бита
            
            if isColumn {
                if canStack(card: sCards[column][row].card, onCard: onCard, isColumn: isColumn) {
                    return index
                }
            } else {
                if numberOfCards == 1 { // в биту можно положить 1 карту за раз
                    if canStack(card: sCards[column][row].card, onCard: onCard, isColumn: isColumn) {
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
            for row in sCards[column].indices {
                if !sCards[column][row].card.isOpen {
                    return
                }
            }
        }

        timerIsActive = false
        timerTask?.cancel()
        
        withAnimation { gameOver = true }
    }
    
    private func backCardsToStartStack(_ index: Int) {
        guard let (column, row) = columnAndRowFor(card: index) else { return }

        let count = sCards[column].count
        (row..<count).forEach { sCardIndex in
            let gCardIndex = sCards[column][sCardIndex].index
            gCards[gCardIndex].moving = nil
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
        movesNumber += 1
        pointsCoefficient = "x " + timeAndMovesCoefficient().toStr
        
        game.movesNumber = movesNumber
        
        startTimerIfNeeded()
    }
    
    private func onTime() {
        timeNumber += 1
        pointsCoefficient = "x " + timeAndMovesCoefficient().toStr
        timeStr = timeNumber.toTime
        
        game.timeNumber = timeNumber
        
        if timerIsActive { startTimer() }
    }
    
    private func startTimerIfNeeded() {
        guard !timerIsActive, !gameOver else { return }
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
        if movesNumber < 40 && timeNumber < 120 {
            return 3
        } else if movesNumber < 50 && timeNumber < 160 {
            return 2.8
        } else if movesNumber < 60 && timeNumber < 180 {
            return 2.6
        } else if movesNumber < 70 && timeNumber < 200 {
            return 2.4
        } else if movesNumber < 80 && timeNumber < 220 {
            return 2.2
        } else if movesNumber < 90 && timeNumber < 260 {
            return 2
        } else if movesNumber < 100 && timeNumber < 280 {
            return 1.6
        } else if movesNumber < 110 && timeNumber < 300 {
            return 1.4
        }

        return 1
    }
    
    private func calculatePoints() {
        let coefficient = timeAndMovesCoefficient()
        
        pointsNumber += Int(10 * coefficient)
        
        game.points = pointsNumber
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
