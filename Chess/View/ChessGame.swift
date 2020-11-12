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
    /* Might not be needed
    func isSelected(_ row: Int, _ col: Int) -> Bool {
        guard let selected = chess.selected else {
            return false
        }
        return selected.row == row && selected.col == col
    }
    */
    func newGame() {
        chess.newGame()
    }
    
    func select(_ row: Int, _ col: Int) {
        chess.select(row, col)
    }
}
