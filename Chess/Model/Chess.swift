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
    var hasMoved = false
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
    private(set) var turn = 1
    var whosTurn: Team {
        (turn % 2 == 0) ? .black : .white
    }
    var whiteTurns: Int {
        Int(ceil(Double(turn - 1) / 2.0))
    }
    var blackTurns: Int {
        (turn - 1) / 2
    }
    
    static let whiteBackRow = 7
    static let blackBackRow = 0
    static let kingColumn = 4
    
    var whiteKingLocation = Coordinates(whiteBackRow, kingColumn)
    var blackKingLocation = Coordinates(blackBackRow, kingColumn)
    
    private var chessPieceCounter: Int = 0
    
    var selected: Coordinates? {
        didSet {
            if selected != nil {
                calculateSelectedPossibleMoves()
                print("Selected: \(selected)")
            }
            else {
                board[oldValue!.row][oldValue!.col].highlight = false
                possibleMoves = nil
                print("Deselected")
            }
        }
    }
    var possibleMoves: [Coordinates]? {
        didSet {
            if possibleMoves != nil {
                highlightPossibleMoves()
                print("Possible moves highlighted: \(possibleMoves)")
            }
            else {
                unhighlightMoves(oldValue)
                print("Unhighted")
            }
        }
    }
    
    static let boardSize = 8
    
    // ----------------------------------------------------------------------------------
    // MARK: Chess Initialization Functions
    // ----------------------------------------------------------------------------------
    
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
    
    private mutating func highlightPossibleMoves() {
        guard let moves = possibleMoves else {
            return
        }
        for loc in moves {
            board[loc.row][loc.col].highlight = true
        }
    }
    
    private mutating func unhighlightMoves(_ moves: [Coordinates]?) {
        guard let moves = moves else {
            return
        }
        for loc in moves {
            board[loc.row][loc.col].highlight = false
        }
    }
    
    // ----------------------------------------------------------------------------------
    // MARK: Chess API
    // ----------------------------------------------------------------------------------
    
    mutating func newGame() {
        chessPieceCounter = 0
        turn = 1
        
        generateBoard()
        // Set up black
        generateBackRow(forRow: 0, ofTeam: .black)
        generatePawnRow(forRow: 1, ofTeam: .black)
        // Set up white
        generatePawnRow(forRow: 6, ofTeam: .white)
        generateBackRow(forRow: 7, ofTeam: .white)
    }
    
    // ----------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------
    
    mutating func select(_ row: Int, _ col: Int) {
        // Check if first tap
        if canSelect(row, col) {
            selected = Coordinates(row, col)
            board[row][col].highlight = true
        }
        // Check if second tap
        else if let selected = selected {
            if selected == Coordinates(row, col) {
                self.selected = nil
            }
            // Try to move
            else if move(selected, to: Coordinates(row, col)) {
                self.selected = nil
            }
            // Else player tapped an impossible move
            // keep the selection
        }
    }
    private func canSelect(_ row: Int, _ col: Int) -> Bool {
        selected == nil && board[row][col].chessPiece != nil && board[row][col].chessPiece!.team == whosTurn
    }
    
    // ----------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------
    
    mutating func move(_ from: Coordinates, to: Coordinates) -> Bool {
        if !canMove(from, to: to) {
            return false
        }
        
        turn += 1
        
        if from == blackKingLocation || from == whiteKingLocation {
            moveKing(from, to: to)
        }
        else {
            board[to.row][to.col].chessPiece = board[from.row][from.col].chessPiece
            board[to.row][to.col].chessPiece?.hasMoved = true
            board[from.row][from.col].chessPiece = nil
        }
        return true
    }
    private func canMove(_ from: Coordinates, to: Coordinates) -> Bool {
        from != to && board[to.row][to.col].highlight
    }
    
    private mutating func moveKing(_ from: Coordinates, to: Coordinates) {
        if isCastle(from, to: to) {
            let rookLocation: Coordinates
            // if king side
            if to.col > from.col {
                rookLocation = Coordinates(from.row, to.col + 1)
                board[to.row][to.col - 1].chessPiece = board[rookLocation].chessPiece
                board[to.row][to.col - 1].chessPiece?.hasMoved = true
                board[rookLocation.row][rookLocation.col].chessPiece = nil
            }
            // queen side
            else {
                rookLocation = Coordinates(from.row, to.col - 2)
                board[to.row][to.col + 1].chessPiece = board[rookLocation].chessPiece
                board[to.row][to.col + 1].chessPiece?.hasMoved = true
                board[rookLocation.row][rookLocation.col].chessPiece = nil
            }
        }
        board[to.row][to.col].chessPiece = board[from.row][from.col].chessPiece
        board[to.row][to.col].chessPiece?.hasMoved = true
        board[from.row][from.col].chessPiece = nil
        
        switch from {
        case blackKingLocation:
            blackKingLocation = to
        case whiteKingLocation:
            whiteKingLocation = to
        default:
            print("ERROR: This should never happen")
        }
    }
    private func isCastle(_ from: Coordinates, to: Coordinates) -> Bool {
        guard let king = board[from].chessPiece, king.pieceType == .king, !king.hasMoved else {
            return false
        }
        
        return !Util.areAdjacent(from, to)
    }
    
    // ----------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------
    
    private mutating func calculateSelectedPossibleMoves() {
        print("calculating possible moves...")
        guard let selected = selected, let piece = board[selected.row][selected.col].chessPiece else {
            print("guard failed, nil possible moves")
            possibleMoves = nil
            return
        }
        switch piece.pieceType {
        case .pawn:
            print("calculating pawn moves...")
            possibleMoves = ChessRules.pawnMoves(from: selected, forPiece: piece, on: board)
        case .rook:
            possibleMoves = ChessRules.rookMoves(from: selected, forPiece: piece, on: board)
        case .knight:
            possibleMoves = ChessRules.knightMoves(from: selected, forPiece: piece, on: board)
        case .bishop:
            possibleMoves = ChessRules.bishopMoves(from: selected, forPiece: piece, on: board)
        case .queen:
            possibleMoves = ChessRules.queenMoves(from: selected, forPiece: piece, on: board)
        case .king:
            possibleMoves = ChessRules.kingMoves(from: selected, forPiece: piece, on: board)
        }
    }
}
