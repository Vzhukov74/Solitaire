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
            RoundedRectangle(cornerRadius: 4)
                            .foregroundColor(Color.gray)
        }

    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card(suit: .diamonds, rank: .ace))
    }
}


struct Card: Hashable, Identifiable {
    enum Suit: CaseIterable {
        case clubs, diamonds, hearts, spades
    }

    enum Rank: Int, CaseIterable {
        case ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king
    }
    
    let id = UUID()
    let suit: Suit
    let rank: Rank
    var isOpen: Bool = false
    var isHide: Bool = false
}

extension Card.Rank {
    var next: Self {
        var nextRaw = rawValue + 1
        if nextRaw > 12 {
            nextRaw = 0
        }
        return Self(rawValue: nextRaw)!
    }
}



extension Card.Suit {
    var title: String {
        switch self {
        case .clubs: return "♣︎"
        case .diamonds: return "♦︎"
        case .hearts: return "♥︎"
        case .spades: return "♠︎"
        }
    }
    
    var color: Color {
        switch self {
        case .clubs, .spades: return Color.black
        case .hearts, .diamonds: return Color.red
        }
    }
}

extension Card.Rank {
    var title: String {
        switch self {
        case .ace: return "A"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .ten: return "10"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        }
    }
}
