//
//  LogoView.swift
//  Solitaire
//
//  Created by v.s.zhukov on 24.01.2022.
//

import SwiftUI

struct LogoView: View {
    @State private var cardRotationAngle: Double = 0
    @State private var cardScale: Double = 0.7
    
    private var width: Double { UIScreen.main.bounds.width * 0.5 }
    private var height: Double { 1.5 * width }
    
    var body: some View {
            ZStack(alignment: .center) {
                Image("A♦")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: 1.5 * width)
                    .rotationEffect(.degrees(-1 * cardRotationAngle ), anchor: .bottom)
                    .scaleEffect(cardScale)
                
                Image("A♥")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: 1.5 * width)
                    .scaleEffect(cardScale)
                
                Image("A♠")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: 1.5 * width)
                    .rotationEffect(.degrees(cardRotationAngle), anchor: .bottom)
                    .scaleEffect(cardScale)
                
                Image("A♣")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: 1.5 * width)
                    .rotationEffect(.degrees(2 * cardRotationAngle), anchor: .bottom)
                    .scaleEffect(cardScale)
            }
            .rotationEffect(.degrees(-4), anchor: .bottom)
            .onAppear {
                withAnimation {
                    cardRotationAngle = 12
                    cardScale = 1
                }
            }
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
