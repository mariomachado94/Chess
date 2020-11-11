//
//  ChessViewModel.swift
//  Chess
//
//  Created by Mario Machado on 2020-11-10.
//

import SwiftUI

class ChessViewModel: ObservableObject {
    @Published var chessGame: ChessGame = ChessGame()
    
    var chessBoard: [[ChessPiece?]] {
        chessGame.board
    }
    
    func isSelected(_ row: Int, _ col: Int) -> Bool {
        guard let selected = chessGame.selected else {
            return false
        }
        return selected.row == row && selected.col == col
    }
    
    func newGame() {
        chessGame.newGame()
    }
    
    func select(_ row: Int, _ col: Int) {
        chessGame.select(row, col)
    }
}
