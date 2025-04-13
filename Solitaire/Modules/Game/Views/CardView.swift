//
//  CardView.swift
//  card game
//
//  Created by Владислав Жуков on 21.04.2024.
//

import SwiftUI

struct CardView: View {
    let card: Card
    let isOpen: Bool
    
    let front: Image
    let back: Image
    
    var body: some View {
        if isOpen {
            front.resizable()
        } else {
            back.resizable()
        }
    }
}
