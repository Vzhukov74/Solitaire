//
//  GameTableViewModel.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI

final class GameTableViewModel: ObservableObject {

    @Published var state: SolitaireState
    @Published var ui: SolitaireGameUIModel
    
    // use as temp for moving card by hand
    @Published var moving: SolitaireState?
    
    let layout: ICardLayout
    let feedbackService: IFeedbackService
    
    private let gameEngine: SolitaireGameEngine
    private let moveEngine: SolitaireMoveCardEngine
    private let gameStore: IGamePersistentStore
    
    // timer
    private var timerTask: Task<Void, Never>?
    private var timerIsActive = false
    private var isPauseBetweenMoves = false
    private var history: [SolitaireState] = []
    
    init(
        with game: SolitaireGame?,
        gameStore: IGamePersistentStore,
        feedbackService: IFeedbackService,
        layout: ICardLayout
    ) {
        self.gameStore = gameStore
        self.feedbackService = feedbackService
        self.layout = layout
        self.gameEngine = SolitaireGameEngine(layout: layout)
        self.moveEngine = SolitaireMoveCardEngine(layout: layout)
        self.state = SolitaireState()
        self.ui = SolitaireGameUIModel()

        self.state = game?.state ?? gameEngine.vm()
        self.history = game?.history ?? []
        
        updateUIModel(for: state)
    }
        
    func newGame() {
        stopTimer()
        state = gameEngine.vm()
        gameEngine.update(for: state)
        ui = SolitaireGameUIModel()
    }
    
    func clear() {
        stopTimer()
    }

    // MARK: public
    func cancelMove() {
        guard var oldState = history.popLast() else { return }
        gameEngine.update(for: oldState)
        oldState.movesNumber += 2
        state = oldState
        updateUIModel(for: state)
        save()
    }
    
    func onAuto() { // add move
        withAnimation { applay(gameEngine.auto(for: state)) }

        guard !ui.gameOver else { return }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 125_000_000)
            onAuto()
        }
    }
    
    func moveCardIfPossible(index: Int) {
        guard state.cards[index].isOpen || state.cards[index].column == .stockInd else { return }
        guard !onPause() else { return }

        if let newState = gameEngine.moveCardIfPossible(index: index, for: state) {
            applay(newState)
        } else { // on error
            state.movesNumber += 1
            state.cards[index].error += 1
            save()
        }
    }
    
    // возвращаем открытые карты из дополнительной стопки обратно в стопку
    func refreshExtraCards() {
        guard !onPause() else { return }
        applay(gameEngine.returnTalonCardsBack(for: state))
    }
        
    func movingCards(_ index: Int, at position: CGPoint) {
        guard state.cards[index].isOpen else { return }
        guard !isPauseBetweenMoves else { return }

        moving = moveEngine.move(index: index, to: position, for: state)
    }
    
    func endMovingCards(_ index: Int, at position: CGPoint) {
        guard !isPauseBetweenMoves else { return }
        guard let moving else { return }

        if let to = moveEngine.endMove(index: index, to: position, for: moving),
           let newState = gameEngine.move(index: index, to: to, for: moving)
        {
            applay(newState)
        } else {
            var newState = moveEngine.backMovingCard(for: moving)
            gameEngine.updateColumnZIndexAfter(column: newState.cards[index].column)
            newState.movesNumber += 1
            state = newState
            save()
        }

        self.moving = nil
        moveEngine.clear()
    }
    
    // MARK: private
    
    private func stopTimer() {
        timerIsActive = false
        timerTask?.cancel()
    }
    
    private func applay(_ newState: SolitaireState) {
        guard newState != state else { return }
        var newState = newState
        
        history.append(state)
        if history.count > .historySize {
            history.remove(at: 0)
        }
        
        updateUIModel(for: newState)
        
        let coefficient = timeAndMovesCoefficient()
        newState.pointsNumber += Int(10 * coefficient)
        newState.movesNumber += 1

        state = newState
        
        if ui.gameOver {
            stopTimer()
            gameStore.reset()
        } else {
            save()
            startTimerIfNeeded()
        }
    }
    
    private func save() {
        gameStore.save(
            SolitaireGame(
                state: state,
                history: history
            )
        )
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
    
    private func onTime() {
        state.timeNumber += 1
        updateUIModel(for: state)
        save()
        
        if timerIsActive { startTimer() }
    }
    
    private func startTimerIfNeeded() {
        guard !timerIsActive, !ui.gameOver else { return }
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
    
    private func updateUIModel(for state: SolitaireState) {
        ui.hasCancelMove = !history.isEmpty
        ui.pointsCoefficient = "x " + timeAndMovesCoefficient().toStr
        ui.timeStr = state.timeNumber.toTime
        
        if !ui.hasAllCardOpened, gameEngine.opendAllCards(for: state) {
            ui.hasAllCardOpened = true
        }

        if !ui.gameOver, gameEngine.allCardsInFStacks(for: state) {
            ui.gameOver = true
        }
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
//        let data = Data(base64Encoded: gStateStr)
//        let gState = try! JSONDecoder().decode(GameState.self, from: data!)
//        self.state = gState
