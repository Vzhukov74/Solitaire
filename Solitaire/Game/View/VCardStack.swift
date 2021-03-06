//
//  VCardStack.swift
//  Solitaire
//
//  Created by v.s.zhukov on 19.11.2021.
//

import SwiftUI

struct VCardStack: View {
    let cards: [Card]
    var animation: Namespace.ID
    
    var onChanged: (_ card: Card, _ location: CGPoint) -> Void
    var onEnded: (_ card: Card, _ location: CGPoint) -> Void
    var onTap: (_ card: Card) -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(Color.black.opacity(0.3))
                    .frame(width: geo.size.width, height: geo.size.width * 1.5)
                
                ForEach(0..<cards.count, id: \.self) { index in
                    CardView(card: cards[index])
                        .frame(width: geo.size.width, height: geo.size.width * 1.5)
                        .offset(x: 0, y: CGFloat(index * 24))
                        .gesture (
                            DragGesture(coordinateSpace: .named("screen"))
                                .onChanged { value in
                                    guard cards[index].isOpen else { return }
                                    onChanged(cards[index], value.location)
                                }.onEnded { value in
                                    onEnded(cards[index], value.location)
                                }
                        )
                        .onTapGesture {
                            guard cards[index].isOpen else { return }
                            onTap(cards[index])
                        }
                        .opacity(cards[index].isHide ? 0 : 1)
                        .matchedGeometryEffect(id: cards[index].id, in: animation)
                }
            }
        }
    }
}






//struct ColumnView_Previews: PreviewProvider {
//    static var previews: some View {
//        ColumnView([Card(suit: .diamonds, rank: .ace), Card(suit: .clubs, rank: .ace), Card(suit: .hearts, rank: .ace)])
//    }
//}
