//
//  ChessBoard.swift
//  Chess
//
//  Created by Mario Machado on 2020-11-10.
//

import Foundation

enum Team {
    case white, black
}
enum PieceType {
    case king, queen, rook, bishop, knight, pawn
}
struct ChessPiece: Identifiable {
    let id: Int
    let team: Team
    let pieceType: PieceType
}

struct Coordinates: Equatable {
    var row: Int
    var col: Int
    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
}
struct ChessGame {
    private(set) var board: [[ChessPiece?]] = []
    private var chessPieceCounter: Int = 0
    var selected: Coordinates?
    
    static let boardSize = 8
    
    init() {
        newGame()
    }
    private mutating func generateBackRow(_ team: Team) -> [ChessPiece] {
        chessPieceCounter += 8
        return Array<ChessPiece>(arrayLiteral:
            ChessPiece(id: chessPieceCounter-7, team: team, pieceType: .rook),
            ChessPiece(id: chessPieceCounter-6, team: team, pieceType: .knight),
            ChessPiece(id: chessPieceCounter-5, team: team, pieceType: .bishop),
            ChessPiece(id: chessPieceCounter-4, team: team, pieceType: .queen),
            ChessPiece(id: chessPieceCounter-3, team: team, pieceType: .king),
            ChessPiece(id: chessPieceCounter-2, team: team, pieceType: .bishop),
            ChessPiece(id: chessPieceCounter-1, team: team, pieceType: .knight),
            ChessPiece(id: chessPieceCounter, team: team, pieceType: .rook)
        )
    }
    private mutating func generatePawnRow(_ team: Team) -> [ChessPiece] {
        var pawns: [ChessPiece] = []
        for _ in 0..<ChessGame.boardSize {
            chessPieceCounter += 1
            pawns.append(ChessPiece(id: chessPieceCounter, team: team, pieceType: .pawn))
        }
        return pawns
    }
    
    // ----------------------------------------------------------------------------------
    // MARK: ChessBoard API
    // ----------------------------------------------------------------------------------
    
    mutating func select(_ row: Int, _ col: Int) {
        if selected == nil && board[row][col] != nil {
            selected = Coordinates(row, col)
        }
        else if let selected = selected {
            move(selected, to: Coordinates(row, col))
            self.selected = nil
        }
    }
    
    mutating func move(_ from: Coordinates, to: Coordinates) {
        guard from != to else {
            return
        }
        board[to.row][to.col] = board[from.row][from.col]
        board[from.row][from.col] = nil
    }
    
    mutating func newGame() {
        chessPieceCounter = 0
        board = Array(repeating: Array(repeating: Optional<ChessPiece>.none, count: ChessGame.boardSize), count: ChessGame.boardSize)
        
        // Set up black
        board[0] = generateBackRow(.black)
        board[1] = generatePawnRow(.black)
        // Set up white
        board[6] = generatePawnRow(.white)
        board[7] = generateBackRow(.white)
    }
}
