//
//  GameTableView.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI

struct GameTableView: View {
    @StateObject var vm: GameTableViewModel
    
    @Binding var isPresenting: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            headerView
            GeometryReader { geo in
                ZStack {
                    pilesBgView

                    PileView(title: "", size: vm.cardSize)
                        .position(vm.extra)
                        .onTapGesture { withAnimation { vm.refreshExtraCards() } }

                    ForEach(vm.columns.indices, id: \.self) {
                        PileView(title: "", size: vm.cardSize)
                            .position(vm.columns[$0])
                    }

                    ForEach(vm.gCards.indices, id: \.self) { index in
                        card(card: vm.gCards[index])
                            .onTapGesture { withAnimation { vm.moveCardIfPossible(index: index) } }
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        vm.movingCards(index, at: value.location)
                                    }
                                    .onEnded { value in
                                        withAnimation { vm.endMovingCards(index, at: value.location) }
                                    }
                            )
                    }
                    
                    if vm.gameOver {
                        Text("Готово").onTapGesture { withAnimation { vm.newGame() } }
                    }
                }
            }
                .padding(8)
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 16) {
            Text("ходы: \(vm.movesNumber, format: .number)")
            Spacer(minLength: 0)
            Button(
                action: { withAnimation { vm.cancelMove() } },
                label: { Text("Отменить")}
            )
                .disabled(!vm.hasCancelMove)
            Button(
                action: { vm.save(); isPresenting = false },
                label: { Text("Закрыть")}
            )
        }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background {
                Capsule().foregroundColor(.cyan)
            }
            .padding(.top, 24)
            .padding(.horizontal, 8)
    }
    
    private var pilesBgView: some View {
        ForEach(vm.piles.indices, id: \.self) {
            PileView(title: "A", size: vm.cardSize)
                .position(vm.piles[$0])
        }
    }
    
    func card(card: CardViewModel) -> some View {
        return CardView(card: card.card)
            .frame(width: vm.cardSize.width, height: vm.cardSize.height)
            .position(card.moving ?? card.position)
            .zIndex(card.moving != nil ? Double(card.movingZIndex) : Double(card.zIndex))
            .modifier(Shake(animatableData: CGFloat(card.error)))
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 5
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
