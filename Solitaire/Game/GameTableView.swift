//
//  GameTableView.swift
//  Solitaire
//
//  Created by v.s.zhukov on 21.01.2022.
//

import SwiftUI

struct GameTableView: View {
    @StateObject var vm: GameTableViewModel
    @Namespace private var animation
    
    private let spacing: CGFloat = 8
    
    var body: some View {
        ZStack {
            pilesBgView
        
            ForEach(vm.columns.indices, id: \.self) {
                PileView(title: "", size: vm.cardSize)
                    .position(vm.columns[$0])
            }
            
            ForEach(vm.cards.indices, id: \.self) { column in
                ForEach(vm.cards[column].indices, id: \.self) { row in
                    card(column, row)
                }
            }
        }
            .coordinateSpace(name: "screen")
            .padding(8)
            .background(Color(UIColor.systemGreen).ignoresSafeArea(edges: .all))
    }
    
    @ViewBuilder
    private var pilesBgView: some View {
        ForEach(vm.piles.indices, id: \.self) {
            PileView(title: "A", size: vm.cardSize)
                .position(vm.piles[$0])
        }
    }
    
    func card(_ column: Int, _ row: Int) -> some View {
        let cardVM = vm.cards[column][row]
        
        return CardView(card: cardVM.card)
            .frame(width: vm.cardSize.width, height: vm.cardSize.height)
            .position(cardVM.moving ?? cardVM.position)
            .zIndex(Double(cardVM.zIndex))
            .gesture (
                DragGesture(coordinateSpace: .named("screen"))
                    .onChanged { value in
                        vm.movingCards(column, row, at: value.location)
                    }.onEnded { value in
                        if let targetColumn = vm.targetColumn(column, row, at: value.location) {
                            withAnimation {
                                vm.moveCards(column, row, targetColumn)
                            } completion: {
                                vm.moveCardsCompletion(column, row, targetColumn)
                            }
                        } else {
                            withAnimation {
                                vm.backCardsToStartStack(column, row)
                            }
                        }
                    }
            )
            .onTapGesture {
                withAnimation {
                    if let targetColumn = vm.targetColumnByTap(column, row) {
                        withAnimation {
                            vm.moveCards(column, row, targetColumn)
                        } completion: {
                            vm.moveCardsCompletion(column, row, targetColumn)
                        }
                    } else {

                    }
                }
            }
    }
}
