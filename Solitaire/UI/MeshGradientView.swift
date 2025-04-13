//
//  MeshGradientView.swift
//  card game
//
//  Created by Vladislav Zhukov on 05.04.2025.
//

import SwiftUI

@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
struct MeshGradientView: View {
    @State var isAnimating = false
    
    var body: some View {
        MeshGradient(width: 3, height: 3, points: [
            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
            [0.0, 0.5], [isAnimating ? 0.1 : 0.8, 0.5], [1.0, isAnimating ? 0.5 : 1],
            [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
        ], colors: [
            Color("gb_1"), Color("gb_4"), Color("gb_1"),
            isAnimating ? Color("gb_3") : Color("gb_1"), Color("gb_1"), Color("gb_1"),
            Color("gb_2"), Color("gb_4"), Color("gb_1")
        ])
        .edgesIgnoringSafeArea(.all)
        .onAppear() {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                isAnimating.toggle()
            }
        }
    }
}
