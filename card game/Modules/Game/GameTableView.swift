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
    
    let uiSettings: IGameUISettingsService
    
    var body: some View {
        VStack(spacing: 8) {
            headerView
            GeometryReader { geo in
                ZStack {
                    pilesBgView

                    PileView(title: "", icon: Image(systemName: "arrow.clockwise"), size: vm.cardSize)
                        .position(vm.extra)
                        .onTapGesture { withAnimation { vm.refreshExtraCards() } }

                    ForEach(vm.columns.indices, id: \.self) {
                        PileView(title: "", icon: nil, size: vm.cardSize)
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
                }
            }
                .padding(8)
            HStack {
                Spacer(minLength: 0)
                Button(
                    action: { withAnimation { vm.cancelMove() } },
                    label: {
                        VStack(alignment: .center, spacing: 4) {
                            Circle().foregroundColor(.black.opacity(0.4))
                                .frame(width: 32, height: 32)
                                .overlay {
                                    Image(systemName: "arrow.counterclockwise")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 22, height: 22)
                                        .foregroundColor(.white)
                                }
                            Text("Отменить ход")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white)
                        }
                    }
                )
                    .disabled(!vm.hasCancelMove)
                Spacer(minLength: 0)
            }
                .padding(.bottom, 24)
        }
            .overlay {
                if vm.gameOver {
                    GameOverView(
                        isPresenting: $vm.gameOver,
                        moveNumber: vm.movesNumber,
                        timeNumber: vm.timeStr,
                        pointsNumber: vm.pointsNumber,
                        onNewGame: { withAnimation { vm.newGame() } },
                        onMainScreen: { vm.onMainScreen(); withAnimation { isPresenting = false } }
                    )
                        .transition(.opacity)
                }
            }
            .onDisappear { vm.save() }
    }
    
    private var headerView: some View {
        HStack(spacing: 10) {
            infoView(title: "ходы", value: "\(vm.movesNumber)")
            infoView(title: "время", value: vm.timeStr)
            infoView(title: "очки", subtitle: vm.pointsCoefficient, value: "\(vm.pointsNumber)")
            Spacer(minLength: 0)
            Button(
                action: { withAnimation { isPresenting = false } },
                label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.black)
                }
            )
                .frame(width: 44, height: 44)
        }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background {
                Capsule()
                    .foregroundColor(.cyan)
                    .shadow(radius: 2, x: 0.5, y: 1)
            }
            .padding(.top, 16)
            .padding(.horizontal, 8)
    }
    
    private var pilesBgView: some View {
        ForEach(vm.piles.indices, id: \.self) {
            PileView(title: "A", icon: nil, size: vm.cardSize)
                .position(vm.piles[$0])
        }
    }
    
    func card(card: CardViewModel) -> some View {
        return CardView(
            card: card.card,
            back: uiSettings.cardBack
        )
            .frame(width: vm.cardSize.width, height: vm.cardSize.height)
            .position(card.moving ?? card.position)
            .zIndex(card.moving != nil ? Double(card.movingZIndex) : Double(card.zIndex))
            .modifier(Shake(animatableData: CGFloat(card.error)))
    }
    
    private func infoView(title: String, subtitle: String? = nil, value: String) -> some View {
        VStack(alignment: .center, spacing: 4) {
            HStack(alignment: .center, spacing: 0) {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(2)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(.blue.opacity(0.4))
                        }
                }
            }
            Text(value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
        }
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
