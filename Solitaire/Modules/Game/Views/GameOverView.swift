//
//  GameOverView.swift
//  card game
//
//  Created by Владислав Жуков on 01.05.2024.
//

import SwiftUI

struct GameOverView: View {
    
    @Binding var isPresenting: Bool
    let feedbackService: IFeedbackService
    
    let moveNumber: Int
    let timeNumber: String
    let pointsNumber: Int
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
                        .frame(width: width)
                    Spacer(minLength: 0)
                }
            }
            .onAppear { withAnimation { confettiCannonCounter += 1; scaleFactor1 = 1.3; scaleFactor2 = 1.3 } ; feedbackService.won() }
            .onTapGesture { withAnimation { confettiCannonCounter += 1; scaleFactor1 = 1.3; scaleFactor2 = 1.3 } }
    }
    
    private var infoView: some View {
        VStack(spacing: 8) {
            Text("Результат")
                .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                .font(.title)
                .padding(16)
                .foregroundColor(.white)
            
            resultValueView(title: "Ходы", value: "\(moveNumber)")
            resultValueView(title: "Время", value: "\(timeNumber)")
            resultValueView(title: "Очки", value: "\(pointsNumber)")
                .padding(.bottom, 16)
        
            btns
                .padding(.bottom, 16)
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
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(Color(.mainViewBg))
            }
            .padding(.horizontal, 32)
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
    private func resultValueView(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Font.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white)
            Text(value)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
    }
}
