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
enum TileType {
    case primary, secondary
}
enum PieceType {
    case king, queen, rook, bishop, knight, pawn
}
struct ChessPiece: Identifiable {
    let id: Int
    let team: Team
    let pieceType: PieceType
}

struct ChessTile: Identifiable {
    let id: Int
    let tileType: TileType
    let row: Int
    let col: Int
    
    var chessPiece: ChessPiece?
    var highlight = false
}

struct Coordinates: Equatable {
    var row: Int
    var col: Int
    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
}
struct Chess {
    private(set) var board: [[ChessTile]] = []
    private var chessPieceCounter: Int = 0
    var selected: Coordinates?
    
    static let boardSize = 8
    
    init() {
        newGame()
    }
    private mutating func generateBackRow(forRow row: Int, ofTeam team: Team) {
        chessPieceCounter += 8
        let backRow = Array<ChessPiece>(arrayLiteral:
            ChessPiece(id: chessPieceCounter-7, team: team, pieceType: .rook),
            ChessPiece(id: chessPieceCounter-6, team: team, pieceType: .knight),
            ChessPiece(id: chessPieceCounter-5, team: team, pieceType: .bishop),
            ChessPiece(id: chessPieceCounter-4, team: team, pieceType: .queen),
            ChessPiece(id: chessPieceCounter-3, team: team, pieceType: .king),
            ChessPiece(id: chessPieceCounter-2, team: team, pieceType: .bishop),
            ChessPiece(id: chessPieceCounter-1, team: team, pieceType: .knight),
            ChessPiece(id: chessPieceCounter, team: team, pieceType: .rook)
        )
        
        for col in 0..<Chess.boardSize {
            board[row][col].chessPiece = backRow[col]
        }
    }
    private mutating func generatePawnRow(forRow row: Int, ofTeam team: Team) {
        for col in 0..<Chess.boardSize {
            chessPieceCounter += 1
            board[row][col].chessPiece = ChessPiece(id: chessPieceCounter, team: team, pieceType: .pawn)
        }
    }
    private mutating func generateBoard() {
        var count = 0
        board = Array<Array<ChessTile>>()
        for r in 0..<Chess.boardSize {
            var row = Array<ChessTile>()
            for c in 0..<Chess.boardSize {
                row.append(ChessTile(id: count, tileType: tileType(r, c), row: r, col: c, chessPiece: nil))
                count += 1
            }
            board.append(row)
        }
    }
    
    private func tileType(_ row: Int, _ col: Int) -> TileType {
        switch (row + col) % 2 {
        case 0:
            return .primary
        default:
            return .secondary
        }
    }
    
    // ----------------------------------------------------------------------------------
    // MARK: ChessBoard API
    // ----------------------------------------------------------------------------------
    
    mutating func select(_ row: Int, _ col: Int) {
        if selected == nil && board[row][col].chessPiece != nil {
            selected = Coordinates(row, col)
            board[row][col].highlight = true
        }
        else if let selected = selected {
            board[selected.row][selected.col].highlight = false
            move(selected, to: Coordinates(row, col))
            self.selected = nil
        }
    }
    
    mutating func move(_ from: Coordinates, to: Coordinates) {
        guard from != to else {
            return
        }
        board[to.row][to.col].chessPiece = board[from.row][from.col].chessPiece
        board[from.row][from.col].chessPiece = nil
    }
    
    mutating func newGame() {
        chessPieceCounter = 0
        generateBoard()
        
        // Set up black
        generateBackRow(forRow: 0, ofTeam: .black)
        generatePawnRow(forRow: 1, ofTeam: .black)
        // Set up white
        generatePawnRow(forRow: 6, ofTeam: .white)
        generateBackRow(forRow: 7, ofTeam: .white)
    }
}
