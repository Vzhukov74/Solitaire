//
//  GameOverViewModel.swift
//  Solitaire
//
//  Created by Vladislav Zhukov on 22.04.2025.
//

import SwiftUI

final class GameOverViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var isNeedShowNameInput: Bool = false
    @Published var leaders: [LeadersSheet.Leaders] = []

    private let challengeOfDay: Challenge?

    var isItChallengeOfDay: Bool { challengeOfDay != nil }
    let score: SolitaireScore
    let feedbackService: IFeedbackService
    
    var userAskForReview: Bool {
        userInfo.userAskForReview
    }
    
    private let userInfo: UserInfo
    private let network: Network
    
    init(
        userInfo: UserInfo,
        network: Network,
        feedbackService: IFeedbackService,
        score: SolitaireScore,
        challengeOfDay: Challenge? = nil
    ) {
        self.userInfo = userInfo
        self.network = network
        self.feedbackService = feedbackService
        self.score = score
        self.challengeOfDay = challengeOfDay
        
        name = userInfo.userName
        isNeedShowNameInput = name.isEmpty && isItChallengeOfDay
    }
    
    func setUserAskForReview() {
        userInfo.setUserAskForReview()
    }
    
    func sendResult() {
        guard let challengeOfDay else { return }
                
        if !name.isEmpty {
            userInfo.set(name: name)
        }
        
        Task { @MainActor in
            let userName = userInfo.userName.isEmpty ? "unknown" : userInfo.userName
            do {
                try await network.sendResultOfChallenge(
                    name: userName,
                    id: userInfo.userId,
                    points: score.pointsNumber,
                    challenge: challengeOfDay
                )
                
                let resultOfChallenge = try await network.fetchLeadersSheet(id: userInfo.userId)
                
                withAnimation {
                    leaders = resultOfChallenge.leaders
                }
            } catch {
                print(error.localizedDescription)
                withAnimation {
                    leaders = [
                        LeadersSheet.Leaders(
                            id: userInfo.userId,
                            name: userName,
                            points: score.pointsNumber
                        )
                    ]
                }
            }
        }
    }
}

