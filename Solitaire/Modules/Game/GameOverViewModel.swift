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
    
    let isItChallengeOfWeek: Bool
    let score: SolitaireScore
    let feedbackService: IFeedbackService
    
    private let userInfo: UserInfo
    private let network: Network
    
    init(
        userInfo: UserInfo,
        network: Network,
        feedbackService: IFeedbackService,
        score: SolitaireScore,
        isItChallengeOfWeek: Bool = false
    ) {
        self.userInfo = userInfo
        self.network = network
        self.feedbackService = feedbackService
        self.score = score
        self.isItChallengeOfWeek = isItChallengeOfWeek
        
        name = userInfo.userName
        isNeedShowNameInput = name.isEmpty
    }
    
    func sendResult() {
        guard isItChallengeOfWeek else { return }
                
        if !name.isEmpty {
            userInfo.set(name: name)
        }
        
        Task { @MainActor in
            let userName = userInfo.userName.isEmpty ? "unknown" : userInfo.userName
            do {
                let resultOfChallenge = try await network.sendResultOfChallenge(
                    name: userName,
                    id: userInfo.userId,
                    points: score.pointsNumber
                )
                
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
                            points: score.pointsNumber,
                            place: 1
                        )
                    ]
                }
            }
        }
    }
}
