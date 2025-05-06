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
    
    @Published var isGameOver: Bool = false
    @Published var leadersSheet: LeadersSheet?
    
    // use as temp for moving card by hand
    @Published var moving: SolitaireState?
    
    let layout: ICardLayout
    let feedbackService: IFeedbackService
    let isItChallengeOfWeek: Bool
    
    private let gameEngine: SolitaireGameEngine
    private let moveEngine: SolitaireMoveCardEngine
    private let gameStore: IGamePersistentStore
    private let network: Network = Network()
    
    // timer
    private var timerTask: Task<Void, Never>?
    private var timerIsActive = false
    private var isPauseBetweenMoves = false
    private var history: [SolitaireState] = []
    
    //
    private var game: String?
    
    init(
        with game: SolitaireGame?,
        deck: DeckShuffler? = nil,
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

        let rDeck: DeckShuffler
        if let deck {
            self.isItChallengeOfWeek = true
            self.game = nil
            rDeck = deck
        } else {
            self.isItChallengeOfWeek = false
            rDeck = DeckShuffler()
            self.game = rDeck.deckStr
        }
        
        self.state = game?.state ?? gameEngine.vm(for: rDeck)
        self.history = game?.history ?? []
        self.score = game?.score ?? SolitaireScore()
        
        gameEngine.addPoints = { [weak self] _ in
            guard let self else { return }
            let coefficient = self.timeAndMovesCoefficient()
            self.score.pointsNumber += Int(10 * coefficient)
        }
        
        updateUIModel(for: state)
    }
        
    func newGame() {
        stopTimer()
        state = gameEngine.vm()
        ui = SolitaireGameUIModel()
        score = SolitaireScore()
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

        guard !isGameOver else { return }
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
        
        score.movesNumber += 1

        state = newState
        
        startTimerIfNeeded()
    }
    
    private func save() {
        guard !isGameOver else { return }
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
        guard !timerIsActive, !isGameOver else { return }
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

        if !isGameOver, gameEngine.allCardsInFStacks(for: state) {
            onEndGame()
        }
    }
    
    private func onEndGame() {
        isGameOver = true

        stopTimer()
        gameStore.reset()
        
        if let game {
            Task {
                try? await network.uploadGame(game: game)
            }
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
