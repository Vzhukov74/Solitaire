//
//  MVCardStack.swift
//  Solitaire
//
//  Created by v.s.zhukov on 21.01.2022.
//

import SwiftUI

struct MVCardStack: View {
    let cards: [Card]
            
    var body: some View {
        GeometryReader { geo in
            if cards.isEmpty {
                Rectangle()
                    .foregroundColor(Color.orange)
                    .frame(width: geo.size.width, height: geo.size.width * 1.5)
            } else {
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: cards[index])
                            .frame(width: geo.size.width, height: geo.size.width * 1.5)
                            .offset(x: 0, y: CGFloat(index * 24))
                    }
                }
            }
        }
    }
}

struct MVCardStack_Previews: PreviewProvider {
    static var previews: some View {
        MVCardStack(cards: [Card(suit: .diamonds, rank: .ace), Card(suit: .clubs, rank: .ace), Card(suit: .hearts, rank: .ace)])
    }
}
