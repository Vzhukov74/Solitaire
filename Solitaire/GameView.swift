//
//  ContentView.swift
//  Solitaire
//
//  Created by v.s.zhukov on 19.10.2021.
//

import SwiftUI

struct GameView: View {
    @StateObject var game: Game
    @Namespace private var animation
    
    private let spacing: CGFloat = 8
    
    var body: some View {
        GeometryReader { geo in

            let cardSize = cardSize(from: geo.size)
            
            ZStack {
                VStack(alignment: .leading) {
                    HStack {
                        HStack {
                            ForEach(0..<game.piles.count, id: \.self) {
                                ZCardStack(cards: game.piles[$0].cards,
                                           animation: animation,
                                           onChanged: game.move,
                                           onEnded: game.stack,
                                           onTap: game.onTap)
                                    .frame(width: cardSize.width, height: cardSize.height)
                            }
                        }
                        
                        Spacer(minLength: spacing)
                        
                        HStack {
                            HCardStack(cards: game.extra.openCards,
                                       animation: animation,
                                       onChanged: game.move,
                                       onEnded: game.stack,
                                       onTap: game.onTap)
                                .frame(height: cardSize.height)
                            
                            Group {
                                if game.extra.cards.isEmpty {
                                    RoundedRectangle(cornerRadius: 4)
                                        .foregroundColor(Color.black.opacity(0.3))
                                } else {
                                    CardView(card: Card.init(suit: .spades, rank: .ace, isOpen: false, isHide: false))  
                                }
                            }
                                .frame(width: cardSize.width, height: cardSize.height)
                                .onTapGesture { game.openCard() }
                        }
                        
                    }
                        .frame(height: cardSize.height)
                    
                    HStack {
                        ForEach(0..<game.columns.count, id: \.self) {
                            VCardStack(cards: game.columns[$0].cards,
                                       animation: animation,
                                       onChanged: game.move,
                                       onEnded: game.stack,
                                       onTap: game.onTap)
                                .frame(width: cardSize.width, height: cardSize.height)
                        }
                    }
                        .frame(height: cardSize.height)
                    Spacer(minLength: 0)
                }
                
                if game.movingCards != nil {
                    MVCardStack(cards: game.movingCards!.cards)
                        .frame(width: cardSize.width, height: cardSize.height)
                        .position(game.movingCards!.position)
                }
            }
        }
        .coordinateSpace(name: "screen")
        .padding(8)
        .background(Color(UIColor.systemGreen).ignoresSafeArea(edges: .all))
    }
    
    private func cardSize(from tableSize: CGSize) -> CGSize {
        let width = (tableSize.width - spacing * 6) / 7
        let height = width * 1.5
        return CGSize(width: width, height: height)
    }
}
