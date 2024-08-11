//
//  GameView.swift
//  card game
//
//  Created by Владислав Жуков on 21.04.2024.
//

import SwiftUI

struct GameView: View {
    @StateObject var vm: GameTableViewModel
    @Binding var isPresenting: Bool
    
    var body: some View {
        HStack {
            Spacer(minLength: 0)
            VStack {
                headerView
                tableView
                footerView
            }
            .frame(width: vm.layout.size.width, height: vm.layout.size.height)
            Spacer(minLength: 0)
        }
        .overlay {
            if vm.state.gameOver {
                GameOverView(
                    isPresenting: $vm.state.gameOver,
                    feedbackService: vm.feedbackService,
                    moveNumber: vm.state.movesNumber,
                    timeNumber: vm.state.timeStr,
                    pointsNumber: vm.state.pointsNumber,
                    width: vm.layout.size.width - 24,
                    onNewGame: { withAnimation { vm.newGame() } },
                    onMainScreen: { vm.onMainScreen(); withAnimation { isPresenting = false } }
                )
                    .transition(.opacity)
            }
        }
        .onDisappear { vm.clear() }
    }
    
    private var tableView: some View {
        CardsTableView(
            cardSize: vm.layout.cardSize,
            columns: vm.layout.columns,
            piles: vm.layout.piles,
            extra: vm.layout.extra,
            cards: vm.state.gCards,
            cardUIServices: AppDI.shared.service(),
            refreshExtraCards: vm.refreshExtraCards,
            moveCardIfPossible: { vm.moveCardIfPossible(index: $0) },
            movingCards: { vm.movingCards($0, at: $1) },
            endMovingCards: { vm.endMovingCards($0, at: $1) }
        )
    }
    
    private var headerView: some View {
        VStack {
            HStack(spacing: 0) {
                Color.clear
                    .frame(width: 44, height: 44)
                    .overlay {
                        HStack {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color("accent"))
                            Spacer(minLength: 0)
                        }
                    }
                    .onTapGesture { withAnimation { isPresenting = false } }
                
                CustomButtonBgShape(lineLength: 50)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(Color("accent"))
                    .frame(height: 44)
                    .overlay {
                        Text(vm.state.timeStr)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: 44)
                    }
                
                Color.clear
                    .frame(width: 44, height: 44)
            }
            HStack(spacing: 10) {
                infoView(title: "очки", subtitle: vm.state.pointsCoefficient, value: "\(vm.state.pointsNumber)")
                Spacer(minLength: 0)
                infoView(title: "ходы", value: "\(vm.state.movesNumber)")
            }
        }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.horizontal, 8)
    }
    
    private var footerView: some View {
        HStack {
            Spacer(minLength: 0)
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: "arrow.counterclockwise")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundColor( vm.state.hasCancelMove ? Color("accent") : Color("accent").opacity(0.3))
                Text("Отменить ход")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor( vm.state.hasCancelMove ? Color("accent") : Color("accent").opacity(0.3))
            }
            .frame(height: 46)
            .padding(.horizontal, 36)
            .background {
                CustomButtonBgShape().foregroundColor(.black.opacity(0.4))
            }
            .onTapGesture {
                if vm.state.hasCancelMove { withAnimation { vm.cancelMove() } }
            }
            Spacer(minLength: 0)
        }
            .padding(.bottom, 24)
    }
    
    private func infoView(title: String, subtitle: String? = nil, value: String) -> some View {
        VStack(alignment: .center, spacing: 4) {
            HStack(alignment: .center, spacing: 0) {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(2)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(.blue.opacity(0.4))
                        }
                }
            }
            Text(value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}
