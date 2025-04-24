//
//  GameOverView.swift
//  card game
//
//  Created by Владислав Жуков on 01.05.2024.
//

import SwiftUI

struct GameOverView: View {
    
    @Binding var isPresenting: Bool
    @StateObject var vm: GameOverViewModel
    @State var isNeedShowNameInput: Bool = false
    
    let width: CGFloat
    
    var onNewGame: () -> Void
    var onMainScreen: () -> Void
    
    @State private var confettiCannonCounter: Int = 0
    @State private var scaleFactor1: CGFloat = 1
    @State private var scaleFactor2: CGFloat = 1
    
    var body: some View {
        Color
            .black
            .opacity(0.6)
            .ignoresSafeArea()
            .overlay {
                VStack {
                    Spacer(minLength: 0)
                    infoView
                        .padding(.top, 48)
                        .frame(width: width)
                        .alert("Введите имя", isPresented: $isNeedShowNameInput) {
                            TextField("имя", text: $vm.name)
                            Button("Готово", role: nil, action: vm.sendResult)
                            Button("Пропущу", role: .cancel, action: { isNeedShowNameInput = false })
                                } message: {
                                    Text("Мы отобразим его в общих результатах недели.")
                                }
                                .onAppear { onAppearAction() }
                    Spacer(minLength: 0)
                }
            }
            .onAppear { withAnimation { confettiCannonCounter += 1; scaleFactor1 = 1.3; scaleFactor2 = 1.3 } ; vm.feedbackService.won() }
            .onTapGesture { withAnimation { confettiCannonCounter += 1; scaleFactor1 = 1.3; scaleFactor2 = 1.3 } }
    }
    
    private var infoView: some View {
        VStack(spacing: 8) {
            gameResulView
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(Color(.mainViewBg))
                }
                .padding(.horizontal, 24)
                

            if vm.isItChallengeOfWeek {
                leadersSheetView
                    .padding(.bottom, 16)
            }

            Spacer(minLength: 0)
            btns
                .padding(.bottom, 24)
                .padding(.horizontal, 24)
        }
        .overlay {
            VStack {
                HStack {
                    Image(.firecrackerLeft)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .offset(x: -5, y: -18)
                        .modifier(ReversingScale(to: scaleFactor1) { self.scaleFactor1 = 1.0 })
                        .animation(.easeInOut, value: scaleFactor1)
                    Circle()
                        .foregroundColor(.clear)
                        .frame(width: 60, height: 60)
                        .confettiCannon(counter: $confettiCannonCounter, num: 40)
                    Spacer(minLength: 0)
                    Circle()
                        .foregroundColor(.clear)
                        .frame(width: 60, height: 60)
                        .confettiCannon(counter: $confettiCannonCounter, num: 40)
                    Image(.firecrackerRight)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .offset(x: 5, y: -18)
                        .modifier(ReversingScale(to: scaleFactor2) { self.scaleFactor2 = 1.0 })
                        .animation(.easeInOut, value: scaleFactor2)
                }
                Spacer(minLength: 0)
            }
        }
    }
    
    private var btns: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Новая игра")
                .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.white)
                .frame(height: 46)
                .padding(.horizontal, 16)
                .background {
                    CustomButtonBgShape().foregroundColor(Color(.accent))
                }
                .onTapGesture { withAnimation { isPresenting = false }; onNewGame() }
                .frame(maxWidth: 320)
                .padding(.horizontal, 32)
            
            Text("На главную")
                .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.white)
                .padding(.horizontal, 16)
                .frame(height: 46)
                .frame(maxWidth: 320)
                .onTapGesture { withAnimation { isPresenting = false }; onMainScreen() }
        }
    }
    
    @ViewBuilder
    private var gameResulView: some View {
        VStack(spacing: 12) {
            Text("Результат")
                .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                .font(.title)
                .padding(16)
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                resultValueView(title: "Ходы", value: "\(vm.score.movesNumber)")
                resultValueView(title: "Время", value: "\(vm.score.timeNumber)")
                resultValueView(title: "Очки", value: "\(vm.score.pointsNumber)")
            }
                .padding(.bottom, 16)
        }
            .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func resultValueView(title: String, value: String) -> some View {
        VStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(Font.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.white)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(Font.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private var leadersSheetView: some View {
        if vm.leaders.isEmpty {
            ProgressView()
        } else {
            LeadersSheetView(leaders: vm.leaders)
                .transition(.opacity)
        }
    }
    
    private func onAppearAction() {
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 500000000)
            if vm.name.isEmpty {
                isNeedShowNameInput = true
            } else {
                vm.sendResult()
            }
        }
    }
}
