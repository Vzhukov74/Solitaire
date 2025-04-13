//
//  SolitaireGameUIModel.swift
//  card game
//
//  Created by Vladislav Zhukov on 13.03.2025.
//

import SwiftUI

struct SolitaireGameUIModel {
    var hasCancelMove: Bool = false
    var gameOver: Bool = false
    var hasAllCardOpened: Bool = false

    var timeStr: String = "0:00"
    var pointsCoefficient: String = "x 3.0"
}
