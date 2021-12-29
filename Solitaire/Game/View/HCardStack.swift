//
//  HCardStack.swift
//  Solitaire
//
//  Created by v.s.zhukov on 29.11.2021.
//

import SwiftUI

struct HCardStack: View {
    let cards: [Card]
    var animation: Namespace.ID
    
    var onChanged: (_ card: Card, _ location: CGPoint) -> Void
    var onEnded: (_ card: Card, _ location: CGPoint) -> Void
    var onTap: (_ card: Card) -> Void
    
    var body: some View {
        GeometryReader { geo in
            if cards.isEmpty {
                EmptyView()
            } else {
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: cards[index])
                            .frame(width: geo.size.height / 1.5)
                            .offset(x: offset(for: index, in: geo.size.width - geo.size.height / 1.5), y: 0)
                            .gesture (
                                DragGesture(coordinateSpace: .named("screen"))
                                    .onChanged { value in
                                        guard index == 0 else { return }
                                        onChanged(cards[index], value.location)
                                    }.onEnded { value in
                                        onEnded(cards[index], value.location)
                                    }
                            )
                            .onTapGesture {
                                guard index == 0 else { return }
                                onTap(cards[index])
                            }
                            .opacity(cards[index].isHide ? 0 : 1)
                            .matchedGeometryEffect(id: cards[index].id, in: animation)
                            .zIndex(Double(2 - index))
                    }
                }
            }
        }
    }
    
    private func offset(for index: Int, in width: CGFloat) -> CGFloat {
        return width - (width  * (CGFloat(index) * 0.5))
    }
}

//struct DeckView_Previews: PreviewProvider {
//    static var previews: some View {
//        HCardStack()
//    }
//}
