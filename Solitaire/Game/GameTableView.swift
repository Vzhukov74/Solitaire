//
//  GameTableView.swift
//  Solitaire
//
//  Created by v.s.zhukov on 21.01.2022.
//

import SwiftUI

struct GameTableView: View {
    @StateObject var viewModel: GameTableViewModel
    @Namespace private var animation
    
    private let spacing: CGFloat = 8
    
    var body: some View {
        GeometryReader { geo in

            let cardSize = cardSize(from: geo.size)
            
            ZStack {
                VStack(alignment: .leading) {
                    HStack {
                        HStack {
                            ForEach(0..<viewModel.game.piles.count, id: \.self) {
                                ZCardStack(cards: viewModel.game.piles[$0],
                                           animation: animation,
                                           onChanged: viewModel.move,
                                           onEnded: viewModel.stack,
                                           onTap: viewModel.onTap)
                                    .frame(width: cardSize.width, height: cardSize.height)
                            }
                        }
                        
                        Spacer(minLength: spacing)
                        
                        HStack {
                            HCardStack(cards: viewModel.game.openCards,
                                       animation: animation,
                                       onChanged: viewModel.move,
                                       onEnded: viewModel.stack,
                                       onTap: viewModel.onTap)
                                .frame(height: cardSize.height)
                            
                            Group {
                                if viewModel.game.extraCards.isEmpty {
                                    RoundedRectangle(cornerRadius: 4)
                                        .foregroundColor(Color.black.opacity(0.3))
                                } else {
                                    CardView(card: Card.init(suit: .spades, rank: .ace, isOpen: false, isHide: false))
                                }
                            }
                                .frame(width: cardSize.width, height: cardSize.height)
                                .onTapGesture { viewModel.openCard() }
                        }
                        
                    }
                        .frame(height: cardSize.height)
                    
                    HStack {
                        ForEach(0..<viewModel.game.columns.count, id: \.self) {
                            VCardStack(cards: viewModel.game.columns[$0],
                                       animation: animation,
                                       onChanged: viewModel.move,
                                       onEnded: viewModel.stack,
                                       onTap: viewModel.onTap)
                                .frame(width: cardSize.width, height: cardSize.height)
                        }
                    }
                        .frame(height: cardSize.height)
                    Spacer(minLength: 0)
                }
                
                if viewModel.movingCards != nil {
                    MVCardStack(cards: viewModel.movingCards!.cards)
                        .frame(width: cardSize.width, height: cardSize.height)
                        .position(viewModel.movingCards!.position)
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
