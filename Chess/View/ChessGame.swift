//
//  ChessViewModel.swift
//  Chess
//
//  Created by Mario Machado on 2020-11-10.
//

import SwiftUI

class ChessGame: ObservableObject {
    @Published var chess: Chess = Chess()
    
    var board: [[ChessTile]] {
        chess.board
    }
    
    var whosTurn: Team {
        chess.whosTurn
    }
    
    var whiteTurns: Int {
        chess.whiteTurns
    }
    
    var blackTurns: Int {
        chess.blackTurns
    }
    
    func newGame() {
        chess.newGame()
    }
    
    func select(_ row: Int, _ col: Int) {
        chess.select(row, col)
    }
    
}
