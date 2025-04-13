//
//  MainViewCardsLogo.swift
//  card game
//
//  Created by Владислав Жуков on 21.04.2024.
//

import SwiftUI

struct MainViewCardsLogo: View {
    @State private var cRotation: Double = 0
    @State private var stackRotation: Double = 0
    @State private var cScale: Double = 0.9
    @State private var yOffset: Double = 70
        
    private var width: Double { 300 * 0.5 }
    private var height: Double { 1.5 * width }
    
    var body: some View {
            ZStack(alignment: .center) {
                Image("lda_1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
                    .rotationEffect(.degrees(-1 * cRotation), anchor: .bottom)
                    .scaleEffect(cScale)
                    .offset(y: yOffset)
                
                Image("lha_1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
                    .scaleEffect(cScale)
                    .offset(y: yOffset)
                
                Image("lca_1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
                    .rotationEffect(.degrees(cRotation), anchor: .bottom)
                    .scaleEffect(cScale)
                    .offset(y: yOffset)
                
                Image("lsa_1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
                    .rotationEffect(.degrees(2 * cRotation), anchor: .bottom)
                    .scaleEffect(cScale)
                    .offset(y: yOffset)
            }
            .rotationEffect(.degrees(stackRotation), anchor: .bottom)
            .onAppear {
                withAnimation {
                    cRotation = 12
                    cScale = 1
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let delta: Double = min(value.location.x - value.startLocation.x, 6)
                        guard delta > 0 else { return }
                        
                        withAnimation {
                            if delta <= 4 {
                                cRotation = 12 - 4 * delta
                                stackRotation = -4 + 1 * delta
                            } else {
                                let coefficient: Double = (delta - 4) / 2
                                cRotation = 0
                                stackRotation = 0
                                cRotation = 0
                                cScale = 1 - 0.2 * coefficient
                                yOffset = 70 * coefficient
                            }
                        }
                    }
                    .onEnded { value in
                        withAnimation {
                            cRotation = 12
                            stackRotation = -4
                            cScale = 1
                            yOffset = 0
                        }
                    }
            )
            .onTapGesture {
                withAnimation {
                    cRotation = 0
                    stackRotation = 0
                    cScale = 0.9
                    yOffset = 70
                }
                Task { @MainActor in
                    try await Task.sleep(nanoseconds: 5_00_000_000)
                    withAnimation {
                        cRotation = 12
                        stackRotation = -4
                        cScale = 1
                        yOffset = 0
                    }
                }
            }
            .onAppear {
                Task { @MainActor in
                    withAnimation {
                        cRotation = 12
                        stackRotation = -4
                        cScale = 1
                        yOffset = 0
                    }
                }
            }
    }
}
