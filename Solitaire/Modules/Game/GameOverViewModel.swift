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
    
    let isItChallengeOfDay: Bool
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
        isItChallengeOfDay: Bool = false
    ) {
        self.userInfo = userInfo
        self.network = network
        self.feedbackService = feedbackService
        self.score = score
        self.isItChallengeOfDay = isItChallengeOfDay
        
        name = userInfo.userName
        isNeedShowNameInput = name.isEmpty && isItChallengeOfDay
    }
    
    func setUserAskForReview() {
        userInfo.setUserAskForReview()
    }
    
    func sendResult() {
        guard isItChallengeOfDay else { return }
                
//        if !name.isEmpty {
//            userInfo.set(name: name)
//        }
//        
//        Task { @MainActor in
//            let userName = userInfo.userName.isEmpty ? "unknown" : userInfo.userName
//            do {
//                let resultOfChallenge = try await network.sendResultOfChallenge(
//                    name: userName,
//                    id: userInfo.userId,
//                    points: score.pointsNumber
//                )
//                
//            } catch {
//                print(error.localizedDescription)
//                withAnimation {
//                    leaders = [
//                        LeadersSheet.Leaders(
//                            id: userInfo.userId,
//                            name: userName,
//                            points: score.pointsNumber,
//                            place: 1
//                        )
//                    ]
//                }
//            }
//        }
    }
}
