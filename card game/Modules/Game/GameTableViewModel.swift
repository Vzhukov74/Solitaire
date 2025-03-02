//
//  GameTableViewModel.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI

final class GameTableViewModel: ObservableObject {

    @Published var state: SolitaireState
    
    let layout: ICardLayout
    let feedbackService: IFeedbackService
    
    private let gameEngine: SolitaireGameEngine
    private let gameStore: IGamePersistentStore
    
    // timer
    private var timerTask: Task<Void, Never>?
    private var timerIsActive = false
    private var isPauseBetweenMoves = false
    private var history: [SolitaireState] = []
    
    init(
        with game: Game?,
        gameStore: IGamePersistentStore,
        feedbackService: IFeedbackService,
        layout: ICardLayout
    ) {
        self.gameStore = gameStore
        self.feedbackService = feedbackService
        self.layout = layout
        self.gameEngine = SolitaireGameEngine(layout: layout)
        self.state = SolitaireState()

        self.state = gameEngine.vm()

//        let data = Data(base64Encoded: gStateStr)
//        let gState = try! JSONDecoder().decode(GameState.self, from: data!)
//        self.state = gState
                
//        if game != nil {
//            self.state = GameState.state(from: game!)
//            state.timeStr = game!.timeNumber.toTime
//            state.pointsCoefficient = "x " + timeAndMovesCoefficient().toStr
//        } else {
//            self.state = GameState.new(with: layout)
//        }
    }
        
    func newGame() {
        resetGame()
        state = gameEngine.vm()
    }
    
    func clear() {
        resetGame()
    }
    
    func onMainScreen() {
//        gameStore.reset()
    }
    
    // MARK: public
    func cancelMove() {
        // reset map in game engine
        guard let oldState = history.popLast() else { return }
        state = oldState
    }
    
    func onAuto() {
        applay(gameEngine.auto(for: state))
        
        if(!state.gameOver) {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 50_000_000)
                onAuto()
            }
        }
    }
    
    func moveCardIfPossible(index: Int) {
        guard state.cards[index].isOpen || state.cards[index].column == .stockInd else { return }
        guard !onPause() else { return }

        if let newState = gameEngine.moveCardIfPossible(index: index, for: state) {
            applay(newState)
        } else { // on error
            state.cards[index].error += 1
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
        
        applay(gameEngine.move(index: index, to: position, for: state))
    }
    
    func endMovingCards(_ index: Int, at position: CGPoint) {
        guard !isPauseBetweenMoves else { return }

        applay(gameEngine.endMove(index: index, to: position, for: state))
    }
    
    // MARK: private
    
    private func resetGame() {
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
        
        newState.hasCancelMove = !history.isEmpty

        if !state.hasAllCardOpened, gameEngine.opendAllCards(for: state) {
            newState.hasAllCardOpened = true
        }
                
        if !state.gameOver, gameEngine.allCardsInFStacks(for: state) {
            newState.gameOver = true
        }
        
        let coefficient = timeAndMovesCoefficient()
        newState.pointsNumber += Int(10 * coefficient)

        //save progress
        
        state = newState
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
