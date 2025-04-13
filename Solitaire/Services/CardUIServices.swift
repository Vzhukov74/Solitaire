//
//  CardUIServices.swift
//  card game
//
//  Created by Владислав Жуков on 16.06.2024.
//

import SwiftUI

protocol ICardUIServices {
    
    var back: Image { get }
    var selectedBackId: String { get }
    var selectedFrontId: String { get }
    var selectedTableId: String { get }
    var allBacks: [(String, Image)] { get }
    var allFronts: [(String, [Image])] { get }
    var allTableBackgrounds: [String] { get }
    
    func select(back id: String)
    func select(front id: String)
    func select(table id: String)
    func front(card: Card) -> Image
}

final class CardUIServices: ICardUIServices {
    
    var back: Image {
        Image("cb_\(selectedBackId)")
    }
    
    @UserDefault(wrappedValue: "2", "com.solitaire.game.card.back.key")
    private(set) var selectedBackId: String
    @UserDefault(wrappedValue: "2", "com.solitaire.game.card.front.key")
    private(set) var selectedFrontId: String
    @UserDefault(wrappedValue: "bg_2", "com.solitaire.game.table.background.key")
    private(set) var selectedTableId: String
        
    var allBacks: [(String, Image)] {
        [
            ("1", Image("cb_1")),
            ("2", Image("cb_2")),
            ("3", Image("cb_3")),
            ("4", Image("cb_4")),
            ("5", Image("cb_5"))
        ]
    }
    
    var allFronts: [(String, [Image])] {
        [
            ("1", [Image("ha_1"), Image("ca_1"), Image("da_1"), Image("sa_1")]),
            ("2", [Image("ha_2"), Image("ca_2"), Image("da_2"), Image("sa_2")])
        ]
    }
    
    var allTableBackgrounds: [String] {
        ["bg_1", "bg_2", "bg_3", "bg_4"]
    }
    
    func select(back id: String) {
        selectedBackId = id
    }
    
    func select(front id: String) {
        selectedFrontId = id
    }
    
    func select(table id: String) {
        selectedTableId = id
    }
    
    func front(card: Card) -> Image {
        Image("\(card.imageSuit)\(card.imageRank)_\(selectedFrontId)")
    }
}

private extension Card {
    var imageSuit: String {
        switch self.suit {
        case .spades:
            return "s"
        case .diamonds:
            return "d"
        case .hearts:
            return "h"
        case .clubs:
            return "c"
        }
    }
    
    var imageRank: String {
        switch self.rank {
        case .ace: return "a"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .ten: return "10"
        case .jack: return "j"
        case .queen: return "q"
        case .king: return "k"
        }
    }
}
