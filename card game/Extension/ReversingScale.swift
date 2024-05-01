//
//  ReversingScale.swift
//  card game
//
//  Created by Владислав Жуков on 01.05.2024.
//

import SwiftUI

struct ReversingScale: AnimatableModifier {
    var value: CGFloat

    private let target: CGFloat
    private let onEnded: () -> ()

    init(to value: CGFloat, onEnded: @escaping () -> () = {}) {
        self.target = value
        self.value = value
        self.onEnded = onEnded // << callback
    }

    var animatableData: CGFloat {
        get { value }
        set { value = newValue
            // newValue here is interpolating by engine, so changing
            // from previous to initially set, so when they got equal
            // animation ended
            let callback = onEnded
            if newValue == target {
                DispatchQueue.main.async(execute: callback)
            }
        }
    }

    func body(content: Content) -> some View {
        content.scaleEffect(value)
    }
}
