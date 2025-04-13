//
//  GameTableViewModel.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI

final class GameTableViewModel: ObservableObject {

    @Published var state: SolitaireState
    @Published var score: SolitaireScore
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
        
        self.ui = SolitaireGameUIModel()

        self.state = game?.state ?? gameEngine.vm()
        self.history = game?.history ?? []
        self.score = game?.score ?? SolitaireScore()

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
        guard let oldState = history.popLast() else { return }
        gameEngine.update(for: oldState)
        score.movesNumber += 1
        state = oldState
        updateUIModel(for: state)
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
        guard gameEngine.isPossibleMoveCard(by: index, for: state) else { return }
        guard !onPause() else { return }

        if let newState = gameEngine.moveCardIfPossible(index: index, for: state) {
            applay(newState)
        } else { // on error
            score.movesNumber += 1
            state.cards[index].error += 1
        }
    }
    
    // возвращаем открытые карты из дополнительной стопки обратно в стопку
    func refreshExtraCards() {
        guard !onPause() else { return }
        applay(gameEngine.returnTalonCardsBack(for: state))
    }
        
    func movingCards(_ index: Int, at position: CGPoint) {
        guard gameEngine.isPossibleMoveCard(by: index, for: state) else { return }
        guard !isPauseBetweenMoves else { return }

        gameEngine.updateColumnZIndex(for: &state)
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
            let newState = moveEngine.backMovingCard(for: moving)
            gameEngine.updateColumnZIndexAfter(column: newState.cards[index].column)
            score.movesNumber += 1
            state = newState
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

        history.append(state)
        if history.count > .historySize {
            history.remove(at: 0)
        }
        
        updateUIModel(for: newState)
        
        let coefficient = timeAndMovesCoefficient()
        score.pointsNumber += Int(10 * coefficient)
        score.movesNumber += 1

        state = newState
        
        if ui.gameOver {
            stopTimer()
            gameStore.reset()
        } else {
            startTimerIfNeeded()
        }
    }
    
    private func save() {
        gameStore.save(
            SolitaireGame(
                state: state,
                score: score,
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
        score.timeNumber += 1
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
        if score.movesNumber < 40 && score.timeNumber < 120 {
            return 3
        } else if score.movesNumber < 50 && score.timeNumber < 160 {
            return 2.8
        } else if score.movesNumber < 60 && score.timeNumber < 180 {
            return 2.6
        } else if score.movesNumber < 70 && score.timeNumber < 200 {
            return 2.4
        } else if score.movesNumber < 80 && score.timeNumber < 220 {
            return 2.2
        } else if score.movesNumber < 90 && score.timeNumber < 260 {
            return 2
        } else if score.movesNumber < 100 && score.timeNumber < 280 {
            return 1.6
        } else if score.movesNumber < 110 && score.timeNumber < 300 {
            return 1.4
        }

        return 1
    }
    
    private func updateUIModel(for state: SolitaireState) {
        ui.hasCancelMove = !history.isEmpty
        ui.pointsCoefficient = "x " + timeAndMovesCoefficient().toStr
        ui.timeStr = score.timeNumber.toTime
        
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
