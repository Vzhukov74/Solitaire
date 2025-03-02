//
//  TableView.swift
//  card game
//
//  Created by Владислав Жуков on 15.07.2024.
//

import SwiftUI

// Нужен только что бы верно посчитать размер для игровой карты
struct TableView: View {
    let gameStore: IGamePersistentStore
    let feedbackService: IFeedbackService
    let game: SolitaireGame?
    
    var body: some View {
        GeometryReader { geo in
            if geo.size.width > 0, geo.size.height > 0 {
                let (size, cardSize) = sizes(from: geo.size)
                GameView(
                    vm: GameTableViewModel(
                        with: game,
                        gameStore: gameStore,
                        feedbackService: feedbackService,
                        layout: CardLayout(size: size, cardSize: cardSize)
                    )
                )
            } else {
                EmptyView()
            }
        }
        .background {
            Color("gb_1").ignoresSafeArea()
        }
    }
    
    private func sizes(from screenSize: CGSize) -> (CGSize, CGSize) {
        let spacing: CGFloat = 6
        let cWidth = min((screenSize.width - spacing * 8) / 7, 64)
        let cHeight = cWidth * 1.5
        
        let width: CGFloat = cWidth * 7 + spacing * 8
                
        return (
            CGSize(width: width, height: screenSize.height),
            CGSize(width: cWidth, height: cHeight)
        )
    }
}
