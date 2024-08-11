//
//  CardLayout.swift
//  card game
//
//  Created by Владислав Жуков on 11.08.2024.
//

import Foundation

/*
    Хранит рассчитанные координаты для положения карт на столе,
    для рассчета берет размер исходного view
 */

protocol ICardLayout {
    var piles: [CGPoint] { get }
    var columns: [CGPoint] { get }
    var extra: CGPoint { get }
    var extraPile: CGPoint { get }
    
    var offsetY: CGFloat { get }
    var spacing: CGFloat { get }

    var size: CGSize { get }
    var cardSize: CGSize { get }
}

final class CardLayout: ICardLayout {
    // MARK: piles coordinate
    private(set) var piles: [CGPoint] = []
    private(set) var columns: [CGPoint] = []
    private(set) var extra: CGPoint = .zero
    private(set) var extraPile: CGPoint = .zero
    private(set) var offsetY: CGFloat = 0
    
    let spacing: CGFloat = 6
    let size: CGSize
    let cardSize: CGSize
    
    init(size: CGSize, cardSize: CGSize) {
        self.size = size
        self.cardSize = cardSize
        
        let width = cardSize.width
        let height = cardSize.height
    
        self.offsetY = height / 3.3
                
        func column(for index: CGFloat, heightDelta: CGFloat = 0) -> CGPoint {
            CGPoint(
                x: width / 2 + (width + spacing) * index,
                y: height / 2 + heightDelta
            )
        }
        
        var indexes: [Int] = Array(0...3)
        self.piles = indexes.map { CGFloat($0) }.compactMap { column(for: $0) }
        
        self.extra = CGPoint(x: size.width - width / 2 - 2 * spacing, y: height / 2)
        self.extraPile = CGPoint(x: extra.x - width - spacing, y: extra.y)
        
        indexes = Array(0...6)
        self.columns = indexes.map { CGFloat($0) }.compactMap { column(for: $0, heightDelta: height + 2 * spacing ) }
    }
}
