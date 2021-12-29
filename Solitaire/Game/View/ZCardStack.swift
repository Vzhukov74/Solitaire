//
//  ZCardStack.swift
//  Solitaire
//
//  Created by v.s.zhukov on 29.11.2021.
//

import SwiftUI

struct ZCardStack: View {
    let cards: [Card]
    
    var animation: Namespace.ID
    
    var onChanged: (_ card: Card, _ location: CGPoint) -> Void
    var onEnded: (_ card: Card, _ location: CGPoint) -> Void
    var onTap: (_ card: Card) -> Void
    
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
                            .gesture (
                                DragGesture(coordinateSpace: .named("screen"))
                                    .onChanged { value in
                                        guard cards[index].isOpen else { return }
                                        onChanged(cards[index], value.location)
                                    }.onEnded { value in
                                        onEnded(cards[index], value.location)
                                    }
                            )
                            .opacity(cards[index].isHide ? 0 : 1)
                            .onTapGesture {
                                guard cards[index].isOpen else { return }
                                onTap(cards[index])
                            }
                            .matchedGeometryEffect(id: cards[index].id, in: animation)
                    }
                }
            }
        }
    }
}

//struct ZCardStack_Previews: PreviewProvider {
//    static var previews: some View {
//        ZCardStack()
//    }
//}
