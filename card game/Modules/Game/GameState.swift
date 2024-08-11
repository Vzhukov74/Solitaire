//
//  GameState.swift
//  card game
//
//  Created by Владислав Жуков on 11.08.2024.
//

import Foundation

struct CardViewModel: Hashable, Codable {
    var card: Card

    var position: CGPoint
    var zIndex: Int = 0
    
    // for game
    var moving: CGPoint?
    var movingZIndex: Int = 0
    var error: Int = 0
        
    func hash(into hasher: inout Hasher) {
        hasher.combine(card)
        hasher.combine(position.x)
        hasher.combine(position.y)
    }
}

struct ShadowCardModel: Codable {
    var card: Card
    let index: Int
}

struct GameState {
    var hasMoves: Bool = true
    var hasCancelMove: Bool = false
    var gameOver: Bool = false
        
    var movesNumber: Int = 0
    var pointsNumber: Int = 0
    var timeNumber: Int = 0
    var timeStr: String = "0:00"
    var pointsCoefficient: String = "x 3.0"
    
    var gCards: [CardViewModel] = []
    var sCards: [[ShadowCardModel]] = []
    
    var gCardsHistory: [[CardViewModel]] = []
    var sCardsHistory: [[[ShadowCardModel]]] = []
}

extension GameState {
    static func new(with layout: ICardLayout) -> GameState {
        let deckShuffler = DeckShuffler()
        
        var state = GameState()
        
        var cards: [CardViewModel] = []
        var sCards: [[ShadowCardModel]] = []
        
        let indexes = Array(0...12)
        var shadowIndex = 0
        indexes.forEach { index in
            if index >= 0, index < 7 {
                var shadowCardsColumn: [ShadowCardModel] = []
                for row in deckShuffler.columns[index].indices {
                    cards.append(
                        CardViewModel(
                            card: deckShuffler.columns[index][row],
                            position: CGPoint(
                                x: layout.columns[index].x,
                                y: layout.columns[index].y + (layout.offsetY / 2) * CGFloat(row)
                            )
                        )
                    )
                    shadowCardsColumn.append(ShadowCardModel(card: deckShuffler.columns[index][row], index: shadowIndex))
                    shadowIndex += 1
                }
                sCards.append(shadowCardsColumn)
            } else if index >= 7, index < 12 {
                cards.append(contentsOf: [])
                sCards.append([])
            } else if index == 12 {
                var shadowCardsColumn: [ShadowCardModel] = []
                for row in deckShuffler.extraCards.indices {
                    cards.append(
                        CardViewModel(
                            card: deckShuffler.extraCards[row],
                            position: layout.extra
                        )
                    )
                    shadowCardsColumn.append(ShadowCardModel(card: deckShuffler.extraCards[row], index: shadowIndex))
                    shadowIndex += 1
                }
                sCards.append(shadowCardsColumn)
            }
        }

        state.gCards = cards
        state.sCards = sCards
        
        return state
    }
    
    static func state(from save: Game) -> GameState {
        var state = GameState()
        
        state.hasCancelMove = !save.sCardsHistory.isEmpty
            
        state.gCards = save.gCards
        state.sCards = save.sCards
        state.movesNumber = save.movesNumber
        state.pointsNumber = save.points
        state.timeNumber = save.timeNumber
        state.gCardsHistory = save.gCardsHistory
        state.sCardsHistory = save.sCardsHistory
        
        return state
    }
    
    func game() -> Game {
        let game = Game()
        
        game.gCards = gCards
        game.sCards = sCards
        game.gCardsHistory = gCardsHistory
        game.sCardsHistory = sCardsHistory
        game.movesNumber = movesNumber
        game.points = pointsNumber
        game.timeNumber = timeNumber
        
        return game
    }
}
