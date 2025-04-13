//
//  CustomButtonBgShape.swift
//  card game
//
//  Created by Владислав Жуков on 16.07.2024.
//

import SwiftUI

struct CustomButtonBgShape: Shape {
    
    let offset: CGFloat
    let lineLength: CGFloat
    
    init(offset: CGFloat = 30, lineLength: CGFloat = 0) {
        self.offset = offset
        self.lineLength = lineLength
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        if lineLength == 0 {
            path.move(to: CGPoint(x: 0, y: rect.size.height / 2))
            path.addLine(to: CGPoint(x: offset, y: 0))
            
            path.addLine(to: CGPoint(x: rect.size.width - offset, y: 0))
            path.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height / 2))
            
            path.addLine(to: CGPoint(x: rect.size.width - offset, y: rect.size.height))
            path.addLine(to: CGPoint(x: offset, y: rect.size.height))
            path.addLine(to: CGPoint(x: 0, y: rect.size.height / 2))
        } else {
            path.move(to: CGPoint(x: 0, y: rect.size.height / 2))
            path.addLine(to: CGPoint(x: lineLength, y: rect.size.height / 2))
            path.addLine(to: CGPoint(x: lineLength + offset, y: 0))
            
            path.addLine(to: CGPoint(x: rect.size.width - offset - lineLength, y: 0))
            path.addLine(to: CGPoint(x: rect.size.width - lineLength, y: rect.size.height / 2))
            path.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height / 2))
            path.addLine(to: CGPoint(x: rect.size.width - lineLength, y: rect.size.height / 2))
            
            path.addLine(to: CGPoint(x: rect.size.width - offset - lineLength, y: rect.size.height))
            path.addLine(to: CGPoint(x: lineLength + offset, y: rect.size.height))
            path.addLine(to: CGPoint(x: lineLength, y: rect.size.height / 2))
        }
        
        return path
    }
}
