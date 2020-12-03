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
    case light, dark
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

struct Move {
    let from: Coordinates
    let to: Coordinates
    let secondaryFrom: Coordinates?
    let secondaryTo: Coordinates?
    let captures: ChessPiece?
    let captureLocation: Coordinates?
    
    init(from: Coordinates, to: Coordinates) {
        self.from = from
        self.to = to
        self.secondaryFrom = nil
        self.secondaryTo = nil
        self.captures = nil
        self.captureLocation = nil
    }
    
    init(fromToPairs: [Coordinates]) {
        self.from = fromToPairs[0]
        self.to = fromToPairs[1]
        self.secondaryFrom = fromToPairs[2]
        self.secondaryTo = fromToPairs[3]
        self.captures = nil
        self.captureLocation = nil
    }
    
    init(from: Coordinates, to: Coordinates, captures: ChessPiece) {
        self.init(from: from, to: to, captures: captures, captureLocation: to)
    }
    
    init(from: Coordinates, to: Coordinates, captures: ChessPiece, captureLocation: Coordinates) {
        self.from = from
        self.to = to
        self.captures = captures
        self.captureLocation = captureLocation
        self.secondaryFrom = nil
        self.secondaryTo = nil
    }
}

struct Chess {
    enum State: String {
        case inprogress = "", check = "Check", checkmate = "Checkmate!", draw = "Draw"
    }
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
    
    var moves: [Move] = [] {
        didSet {
            print(moves.last!)
        }
    }
    
    static let whiteBackRow = 7
    static let blackBackRow = 0
    static let kingColumn = 4
    
    var whiteKingLocation = Coordinates(whiteBackRow, kingColumn)
    var blackKingLocation = Coordinates(blackBackRow, kingColumn)
    
    var inCheck: Bool {
        gameInCheck(onTeam: whosTurn)
    }
    var noMoves: Bool {
        !canMove(whosTurn)
    }
    var state: State {
        switch (inCheck, noMoves) {
        case (false, false):
            return .inprogress
        case (true, false):
            return .check
        case (true, true):
            return .checkmate
        case (false, true):
            return .draw
                
        }
    }
    
    private var chessPieceCounter: Int = 0
    
    var selected: Coordinates? {
        didSet {
            if selected != nil {
                calculateSelectedPossibleMoves()
            }
            else {
                guard let oldValue = oldValue else {
                    return
                }
                board[oldValue.row][oldValue.col].highlight = false
                possibleMoves = nil
            }
        }
    }
    var possibleMoves: [Move]? {
        didSet {
            if possibleMoves != nil {
                highlightMoveTos(possibleMoves, highlight: true)
            }
            else {
                highlightMoveTos(oldValue, highlight: false)
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
            return .light
        default:
            return .dark
        }
    }
    
    private mutating func highlightMoveTos(_ moves: [Move]?, highlight: Bool) {
        guard let moves = moves else {
            return
        }
        for move in moves {
            board[move.to.row][move.to.col].highlight = highlight
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
        
        whiteKingLocation = Coordinates(Chess.whiteBackRow, Chess.kingColumn)
        blackKingLocation = Coordinates(Chess.blackBackRow, Chess.kingColumn)
    }
    
    // ----------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------
    
    mutating func select(_ row: Int, _ col: Int) {
        if isDeselect(row, col) {
            selected = nil
        }
        else if canSelect(row, col) {
            selected = nil
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
        board[row][col].chessPiece != nil && board[row][col].chessPiece!.team == whosTurn
    }
    private func isDeselect(_ row: Int, _ col: Int) -> Bool {
        selected != nil && selected!.row == row && selected!.col == col
    }
    
    // ----------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------
    
    mutating func move(_ from: Coordinates, to: Coordinates) -> Bool {
        guard let move = getMove(from, to: to) else {
            return false
        }
        
        turn += 1
        
        if from == blackKingLocation || from == whiteKingLocation {
            trackKingLocation(from, to: to)
        }
        
        board.execute(move)
        moves.append(move)
        return true
    }
    private func getMove(_ from: Coordinates, to: Coordinates) -> Move? {
        possibleMoves?.first(where: { from == $0.from && to == $0.to } )
    }
    
    private mutating func trackKingLocation(_ from: Coordinates, to: Coordinates) {
        switch from {
        case blackKingLocation:
            blackKingLocation = to
        case whiteKingLocation:
            whiteKingLocation = to
        default:
            print("ERROR: This should never happen")
        }
    }
    
    // ----------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------
    
    private mutating func calculateSelectedPossibleMoves() {
        guard let selected = selected else {
            return
        }
        
        possibleMoves = calculatePossibleMoves(at: selected)
    }
    
    private func calculatePossibleMoves(at location: Coordinates) -> [Move] {
        guard let piece = board[location].chessPiece else {
            return []
        }
        
        var potentialMoves: [Move]
        switch piece.pieceType {
        case .pawn:
            potentialMoves = Movement.pawnMoves(from: location, forPiece: piece, on: board, lastMove: moves.last)
        case .rook:
            potentialMoves = Movement.rookMoves(from: location, forPiece: piece, on: board)
        case .knight:
            potentialMoves = Movement.knightMoves(from: location, forPiece: piece, on: board)
        case .bishop:
            potentialMoves = Movement.bishopMoves(from: location, forPiece: piece, on: board)
        case .queen:
            potentialMoves = Movement.queenMoves(from: location, forPiece: piece, on: board)
        case .king:
            potentialMoves = Movement.kingMoves(from: location, forPiece: piece, on: board)
        }
        
        potentialMoves = potentialMoves.filter{ ensureNoSelfCheck(forMove: $0) }
        return potentialMoves
    }
    
    private func canMove(_ team: Team) -> Bool {
        let kingLocation = team == .white ? whiteKingLocation : blackKingLocation
        if calculatePossibleMoves(at: kingLocation).count > 0 {
            return true
        }
        
        // Check every other piece
        for row in 0..<board.count {
            for col in 0..<board[0].count {
                guard let piece = board[row][col].chessPiece, piece.team == team else {
                    continue
                }
                if calculatePossibleMoves(at: Coordinates(row, col)).count > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    private func gameInCheck(onTeam team: Team) -> Bool {
        let kingLocation = team == .white ? whiteKingLocation : blackKingLocation
        return board.underAttack(at: kingLocation, byTeam: Util.opposingTeam(of: team))
    }
    
    private func ensureNoSelfCheck(forMove move: Move) -> Bool {
        ensureNoSelfCheck(move.from, to: move.to)
    }
    
    private func ensureNoSelfCheck(_ location: Coordinates, to: Coordinates) -> Bool {
        let kingLocation = whosTurn == .white ? whiteKingLocation : blackKingLocation
        if kingLocation != location {
            var potentialBoard = board
            potentialBoard[to.row][to.col].chessPiece = potentialBoard[location.row][location.col].chessPiece
            potentialBoard[location.row][location.col].chessPiece = nil
            return !potentialBoard.underAttack(at: kingLocation, byTeam: Util.opposingTeam(of: whosTurn))
        }
        // If the king is being moved,
        // possiblities have already been checked to be safe
        return true
    }
}
