//
//  CardsTableView.swift
//  card game
//
//  Created by Владислав Жуков on 15.07.2024.
//

import SwiftUI

struct CardsTableView: View {
    
    let layout: ICardLayout
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

                PileView(title: "", icon: Image(systemName: "arrow.clockwise"), size: layout.cardSize)
                    .position(layout.extra)
                    .onTapGesture { withAnimation { refreshExtraCards() } }

                ForEach(layout.columns.indices, id: \.self) {
                    PileView(title: "", icon: nil, size: layout.cardSize)
                        .position(layout.columns[$0])
                }

                ForEach(cards.indices, id: \.self) { index in
                    card(vm: cards[index])
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
        ForEach(layout.piles.indices, id: \.self) {
            PileView(title: "A", icon: nil, size: layout.cardSize)
                .position(layout.piles[$0])
        }
    }

    func card(vm: CardViewModel) -> some View {
        return CardView(
            card: vm.card, isOpen: vm.isOpen,
            front: cardUIServices.front(card: vm.card),
            back: cardUIServices.back
        )
            .frame(width: layout.cardSize.width, height: layout.cardSize.height)
            .position(vm.position)
            .zIndex(Double(vm.zIndex))
            .modifier(Shake(animatableData: CGFloat(vm.error)))
    }
}
