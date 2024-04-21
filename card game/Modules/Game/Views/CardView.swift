//
//  CardView.swift
//  card game
//
//  Created by Владислав Жуков on 21.04.2024.
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
