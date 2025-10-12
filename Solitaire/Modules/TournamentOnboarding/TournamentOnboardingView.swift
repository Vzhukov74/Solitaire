//
//  TournamentOnboardingView.swift
//  Solitaire
//
//  Created by Vladislav Zhukov on 24.09.2025.
//

import SwiftUI

struct ContentBlock: View {
    let index: Int
    
    var body: some View {
        if index == 0 {
            TournamentOnboardingStep1View()
        } else if index == 1 {
            TournamentOnboardingStep2ViewStyled()
        } else {
            TournamentOnboardingStep3View()
        }
    }
}

// Более простая версия с использованием transitions
struct SimpleAnimatedPageView: View {
    @State private var currentBlockIndex = 0
    @State private var isAnimating = false
    
    let onFinish: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Текущий блок контента
                ContentBlock(index: currentBlockIndex)
                .id(currentBlockIndex) // Важно для анимации перехода
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                .frame(maxHeight: .infinity)
                
                VStack(spacing: 16) {
                    if currentBlockIndex == 2 {
                        Button(action: {
                            onCancel()
                        }) {
                            Text("Позже")
                                .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Color("accent"))
                                .frame(height: 46)
                                .padding(.horizontal, 36)
                        }
                        .frame(maxWidth: 320)
                        .disabled(isAnimating)
                    }
                    
                    Button(action: {
                        if currentBlockIndex == 2 {
                            onFinish()
                        } else {
                            Task { await animateTransition() }
                        }
                    }) {
                        Text(buttonText)
                            .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.white)
                            .frame(height: 46)
                            .padding(.horizontal, 36)
                            .background {
                                CustomButtonBgShape().foregroundColor(Color("accent"))
                            }
                    }
                    .frame(maxWidth: 320)
                    .disabled(isAnimating)
                }
                .padding(.bottom, 30)
                .padding(.horizontal, 32)
            }
            .padding(.top, 16)
        }
    }
    
    private var buttonText: String {
        if currentBlockIndex < 2 {
            return "Продолжить"
        } else {
            return "Участвовать"
        }
    }
        
    private func animateTransition() async {
        guard !isAnimating else { return }
        isAnimating = true
        
        let nextIndex: Int
        if currentBlockIndex < 3 {
            nextIndex = currentBlockIndex + 1
        } else {
            nextIndex = 0
        }
        
        // Анимация перехода с использованием withAnimation
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.8)) {
                currentBlockIndex = nextIndex
            }
        }
        
        // Ждем завершения анимации
        try? await Task.sleep(nanoseconds: 800_000_000)
        
        await MainActor.run {
            isAnimating = false
        }
    }
}
