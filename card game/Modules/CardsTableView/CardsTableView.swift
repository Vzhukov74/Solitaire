//
//  CardsTableView.swift
//  card game
//
//  Created by Владислав Жуков on 15.07.2024.
//

import SwiftUI

struct CardsTableView: View {
    let cardSize: CGSize
    let columns: [CGPoint]
    let piles: [CGPoint]
    let extra: CGPoint
    let cards: [CardViewModel]
    let cardUIServices: ICardUIServices
    
    let refreshExtraCards: () -> Void
    let moveCardIfPossible: (Int) -> Void
    let movingCards: (Int, CGPoint) -> Void
    let endMovingCards: (Int, CGPoint) -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                pilesBgView

                PileView(title: "", icon: Image(systemName: "arrow.clockwise"), size: cardSize)
                    .position(extra)
                    .onTapGesture { withAnimation { refreshExtraCards() } }

                ForEach(columns.indices, id: \.self) {
                    PileView(title: "", icon: nil, size: cardSize)
                        .position(columns[$0])
                }

                ForEach(cards.indices, id: \.self) { index in
                    card(card: cards[index])
                        .onTapGesture { withAnimation { moveCardIfPossible(index) } }
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    movingCards(index, value.location)
                                }
                                .onEnded { value in
                                    withAnimation { endMovingCards(index, value.location) }
                                }
                        )
                }
            }
        }
            .padding(8)
    }
    
    private var pilesBgView: some View {
        ForEach(piles.indices, id: \.self) {
            PileView(title: "A", icon: nil, size: cardSize)
                .position(piles[$0])
        }
    }

    func card(card: CardViewModel) -> some View {
        return CardView(
            card: card.card,
            front: cardUIServices.front(card: card.card),
            back: cardUIServices.back
        )
            .frame(width: cardSize.width, height: cardSize.height)
            .position(card.moving ?? card.position)
            .zIndex(card.moving != nil ? Double(card.movingZIndex) : Double(card.zIndex))
            .modifier(Shake(animatableData: CGFloat(card.error)))
    }
}
