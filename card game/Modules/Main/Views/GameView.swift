//
//  GameView.swift
//  card game
//
//  Created by Владислав Жуков on 21.04.2024.
//

import SwiftUI

struct GameView: View {
    
    @Binding var isPresenting: Bool
    
    let gameStore: GameStore
    let feedbackService: IFeedbackService
    let game: Game?
    
    var body: some View {
        GeometryReader { geo in
            if geo.size.width > 0, geo.size.height > 0 {
                let (size, cardSize) = sizes(from: geo.size)
                HStack {
                    Spacer(minLength: 0)
                    GameTableView(
                        vm: GameTableViewModel(
                            with: game,
                            gameStore: gameStore, 
                            feedbackService: feedbackService,
                            size: size,
                            cardSize: cardSize
                        ),
                        isPresenting: $isPresenting,
                        uiSettings: AppDI.shared.service()
                    )
                        .frame(width: size.width, height: size.height)
                }
            } else {
                EmptyView()
            }

        }
        .background(Color.green)
    }
    
    private func sizes(from screenSize: CGSize) -> (CGSize, CGSize) {
        let spacing: CGFloat = 8
        let cWidth = min((screenSize.width - spacing * 8) / 7, 74)
        let cHeight = cWidth * 1.5
        
        let width: CGFloat = cWidth * 7 + spacing * 8
                
        return (
            CGSize(width: width, height: screenSize.height),
            CGSize(width: cWidth, height: cHeight)
        )
    }
}
