//
//  PileView.swift
//  Solitaire
//
//  Created by Владислав Жуков on 29.01.2024.
//

import SwiftUI

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
