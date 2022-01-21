//
//  CardView.swift
//  Solitaire
//
//  Created by v.s.zhukov on 19.10.2021.
//

import SwiftUI

struct CardView: View {
    let card: Card
    
    var body: some View {
        if card.isOpen {
            VStack {
                HStack {
                    Text(card.suit.title + card.rank.title)
                        .font(Font.system(size: 14))
                        .padding(4)
                        .foregroundColor(card.suit.color)
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
                .background(RoundedRectangle(cornerRadius: 4)
                                .foregroundColor(Color.white))
            .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray, lineWidth: 1)
                )
        } else {
            Image("card_back")
                .resizable()
        }

    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card(suit: .diamonds, rank: .ace))
            .frame(width: 100, height: 150)
    }
}
