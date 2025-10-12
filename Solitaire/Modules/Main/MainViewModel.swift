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
    @Published var challengeOfDay: Challenge?
    @Published var showTournamentOnboarding: Bool = false
    
    @Published var challengeOfDayForPlay: Challenge?
    
    let gameStore: IGamePersistentStore
    let scoreStore: ScoreStore
    let network: Network
    let userInfo: UserInfo
    
    init(
        gameStore: IGamePersistentStore,
        scoreStore: ScoreStore,
        network: Network,
        userInfo: UserInfo
    ) {
        self.gameStore = gameStore
        self.scoreStore = scoreStore
        self.network = network
        self.userInfo = userInfo
    }

    func newGame() {
        gameStore.reset()
    }
    
    func checkForSavedGame() {
        hasPausedGame = gameStore.hasSavedGame
        fetchChallengeOfDay()
    }
    
    func didShowTournamentOnboarding() {
        userInfo.setHasSeenTournamentOnboarding()
        showTournamentOnboarding = false
    }
    
    private func fetchChallengeOfDay() {
        showTournamentOnboarding = true
        Task { @MainActor in
            guard challengeOfDay == nil else { return }
            do {
                //try await network.uploadGame(game: "♦3|♠︎5♠︎1|♥︎8♣3♣4|♥︎7♣8♣K♠︎8|♠︎7♦4♦1♣6♣1|♣Q♥︎J♣A♠︎9♥︎Q♠︎6|♣2♦2♠︎4♥︎3♥︎K♦9♦K|♦Q♦6♦7♠︎K♠︎Q♥︎4♦J♠︎2♥︎9♥︎A♣J♥︎5♠︎A♠︎J♥︎6♦8♦5♣9♣7♥︎2♠︎3♥︎1♦A♣5|")
                
                challengeOfDay = try await network.fetchChallengeOfDay()
                //showTournamentOnboarding = !userInfo.hasSeenTournamentOnboarding
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
