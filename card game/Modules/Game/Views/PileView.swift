//
//  PileView.swift
//  card game
//
//  Created by Владислав Жуков on 21.04.2024.
//

import SwiftUI

struct PileView: View {

    let title: String
    let icon: Image?
    let size: CGSize
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .frame(width: size.width, height: size.height, alignment: .center)
            .foregroundColor(Color.black.opacity(0.3))
            .overlay {
                if let icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.width * 0.58, height: size.width * 0.58, alignment: .center)
                        .foregroundColor(Color.white.opacity(0.4))
                } else {
                    Text(title)
                        .font(Font.system(size: 26).bold())
                        .foregroundColor(Color.white.opacity(0.4))
                        .frame(width: size.width, height: size.height, alignment: .center)
                }
            }
    }
}
