//
//  MainViewModel.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    @Published var hasPausedGame: Bool = false
    @Published var presentSettingsScreen: Bool = false
    @Published var challengeOfWeek: DeckShuffler?
        
    let gameStore: IGamePersistentStore
    let scoreStore: ScoreStore
    let network: Network
    
    init(gameStore: IGamePersistentStore, scoreStore: ScoreStore, network: Network) {
        self.gameStore = gameStore
        self.scoreStore = scoreStore
        self.network = network
        
        checkForSavedGame()
    }

    func newGame() {
        gameStore.reset()
    }
    
    func checkForSavedGame() {
        hasPausedGame = gameStore.hasSavedGame
        fetchChallengeOfWeek()
    }
    
    private func fetchChallengeOfWeek() {
        Task { @MainActor in
            guard challengeOfWeek == nil else { return }
            do {
                challengeOfWeek = try await network.fetchChallengeOfWeek()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
