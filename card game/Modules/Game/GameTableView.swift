//
//  GameTableView.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI

struct GameTableView: View {
    @StateObject var vm: GameTableViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            headerView
                .frame(maxWidth: .infinity)
                .frame(height: 60)
            GeometryReader { geo in
                ZStack {
                    pilesBgView

                    PileView(title: "", size: vm.cardSize)
                        .position(vm.extra)
                        .onTapGesture { withAnimation { vm.refreshExtraCards() } }

                    ForEach(vm.columns.indices, id: \.self) {
                        PileView(title: "", size: vm.cardSize)
                            .position(vm.columns[$0])
                    }

                    ForEach(vm.gCards.indices, id: \.self) { index in
                        card(card: vm.gCards[index])
                            .onTapGesture { withAnimation { vm.moveCardIfPossible(index: index) } }
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        vm.movingCards(index, at: value.location)
                                    }
                                    .onEnded { value in
                                        withAnimation { vm.endMovingCards(index, at: value.location) }
                                    }
                            )
                    }
                    
                    if vm.gameOver {
                        Text("Готово").onTapGesture { withAnimation { vm.newGame() } }
                    }
                }
            }
                .padding(8)
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 16) {
            Text("ходы: \(vm.movesNumber, format: .number)")
            Button(
                action: { withAnimation { vm.cancelMove() } },
                label: { Text("Отменить")}
            )
                .disabled(!vm.hasCancelMove)
        }
    }
    
    private var pilesBgView: some View {
        ForEach(vm.piles.indices, id: \.self) {
            PileView(title: "A", size: vm.cardSize)
                .position(vm.piles[$0])
        }
    }
    
    func card(card: CardViewModel) -> some View {
        return CardView(card: card.card)
            .frame(width: vm.cardSize.width, height: vm.cardSize.height)
            .position(card.moving ?? card.position)
            .zIndex(card.moving != nil ? Double(card.movingZIndex) : Double(card.zIndex))
            .modifier(Shake(animatableData: CGFloat(card.error)))
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 5
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

struct Game: Codable {
    let columns: [Deck]
    let extraCards: Deck

    init(with deck: Deck = Deck.initial()) {
        var deck = deck.shuffled()
        
        columns = (1...7).compactMap {
            var cards = Array(deck[0..<$0])
            cards[cards.count - 1].isOpen = true
            deck.removeSubrange(0..<$0)
            return cards
        }

        extraCards = deck
    }
}

extension Deck {
    static func initial() -> Self {
        Card.Suit.allCases.compactMap { suit in
            Card.Rank.allCases.compactMap { Card(suit: suit, rank: $0) }
        }.flatMap { $0 }
    }
}

typealias Deck = [Card]

struct Card: Codable, Hashable, Identifiable {
    enum Suit: Int, Codable, CaseIterable {
        case clubs, diamonds, hearts, spades
        
        var isRed: Bool { self == .hearts || self == .diamonds }
    }

    enum Rank: Int, Codable, CaseIterable {
        case ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king
    }
    
    var id: String { suit.title + rank.title }
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
        case .clubs: return "♣"
        case .diamonds: return "♦"
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

extension Card {
    func canStackOn(card: Card, onPile: Bool) -> Bool {
        if onPile {
            return (self.suit == card.suit) && (self.rank.rawValue - 1 == card.rank.rawValue)
        } else {
            return (self.suit.isRed != card.suit.isRed) && (self.rank.rawValue + 1 == card.rank.rawValue)
        }
    }
}

struct PileView: View {
    
    let title: String
    let size: CGSize
    
    var body: some View {
        Text(title)
            .font(Font.system(size: 26).bold())
            .foregroundColor(Color.white.opacity(0.4))
            .frame(width: size.width, height: size.height, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 4)
                            .foregroundColor(Color.black.opacity(0.3)))
    }
}

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

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    func optionalDragGesture(
        isActive: Bool,
        onChanged: @escaping (CGPoint) -> Void,
        onEnded:  @escaping (CGPoint) -> Void,
        gesture: DragGesture
    ) -> some View {
        Group {
            if isActive {
                self.gesture(
                    gesture
                        .onChanged { value in
                            onChanged(value.location)
                        }.onEnded { value in
                            onEnded(value.location)
                        }
                )
            } else {
                self
            }
        }
    }
    
    func optionalTapGesture(isActive: Bool, action: @escaping () -> Void) -> some View {
        Group {
            if isActive {
                self.onTapGesture { action() }
            } else {
                self
            }
        }
    }
}
