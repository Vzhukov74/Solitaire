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
        
            PileView(title: "", size: vm.cardSize)
                .position(vm.extra)
                .onTapGesture {
                    withAnimation {
                        vm.refreshExtraPile()
                    } completion: {
                        vm.moveCardsToExtraPile()
                    }
                }
            
            ForEach(vm.columns.indices, id: \.self) {
                PileView(title: "", size: vm.cardSize)
                    .position(vm.columns[$0])
            }
            
            ForEach(vm.cards.indices, id: \.self) { index in
                card(index)
            }
            
            if vm.gameOver {
                Text("Готово").onTapGesture {
                    vm.restart()
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
    
    func card(_ index: Int) -> some View {
        let cardVM = vm.cards[index]
        
        return CardView(card: cardVM.card)
            .frame(width: vm.cardSize.width, height: vm.cardSize.height)
            .position(cardVM.moving ?? cardVM.position)
            .zIndex(Double(cardVM.zIndex))
            .gesture (
                DragGesture(coordinateSpace: .named("screen"))
                    .onChanged { value in
                        vm.movingCards(index, at: value.location)
                    }.onEnded { value in
                        if let columns = vm.targetColumn(index, at: value.location) {
                            withAnimation {
                                vm.moveCards(index, columns.0, columns.1)
                            } completion: {
                                //vm.moveCardsCompletion(column, row, targetColumn)
                            }
                        } else {
                            withAnimation {
                                vm.backCardsToStartStack(index)
                            }
                        }
                    }
            )
            .onTapGesture {
                withAnimation {
                    if let columns = vm.targetColumnByTap(index) {
                        vm.moveCards(index, columns.0, columns.1)
//                        withAnimation {
//                            vm.moveCards(column, row, targetColumn)
//                        } completion: {
//                            vm.moveCardsCompletion(column, row, targetColumn)
//                        }
                    } else {

                    }
                }
            }
    }
}
