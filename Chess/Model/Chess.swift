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
    
    /* Moving this into the didset for self.selected
    private mutating func deselect() {
        guard let selected = selected else {
            return
        }
        board[selected.row][selected.col].highlight = false
        self.selected = nil
    }
    */
    
    // ----------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------
    
    mutating func move(_ from: Coordinates, to: Coordinates) -> Bool {
        if !canMove(from, to: to) {
            return false
        }
        
        turn += 1
        board[to.row][to.col].chessPiece = board[from.row][from.col].chessPiece
        board[to.row][to.col].chessPiece?.hasMoved = true
        board[from.row][from.col].chessPiece = nil
        return true
    }
    private func canMove(_ from: Coordinates, to: Coordinates) -> Bool {
        from != to && board[to.row][to.col].highlight
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
            possibleMoves = pawnMoves(from: selected, forPiece: piece)
        case .rook:
            possibleMoves = rookMoves(from: selected, forPiece: piece)
        case .knight:
            possibleMoves = knightMoves(from: selected, forPiece: piece)
        case .bishop:
            possibleMoves = bishopMoves(from: selected, forPiece: piece)
        case .queen:
            possibleMoves = queenMoves(from: selected, forPiece: piece)
        case .king:
            possibleMoves = kingMoves(from: selected, forPiece: piece)
        }
    }
    
    private func pawnMoves(from: Coordinates, forPiece piece: ChessPiece) -> [Coordinates] {
        var moves: [Coordinates] = []
        
        var potentialMove = Coordinates(piece.team == .white ? from.row-1 : from.row+1, from.col)
        if isValidTile(potentialMove) && isEmptyTile(potentialMove) {
            moves.append(potentialMove)
        }
        
        // Hack: moves.count > 0 means first square is empty since it was added as a good move
        // Meaning the order of if's here is important, this should be second
        //
        // Note: !piece.hasMoved will ensure it is always from starting pawn row, index ob is impossible
        potentialMove = Coordinates(piece.team == .white ? from.row-2 : from.row+2, from.col)
        if moves.count > 0 && !piece.hasMoved && isEmptyTile(potentialMove){
            moves.append(potentialMove)
        }
        
        potentialMove = Coordinates(piece.team == .white ? from.row-1 : from.row+1, from.col+1)
        if isValidTile(potentialMove) && containsOpposingTeam(potentialMove, for: piece.team) {
            moves.append(potentialMove)
        }
        
        potentialMove = Coordinates(piece.team == .white ? from.row-1 : from.row+1, from.col-1)
        if isValidTile(potentialMove) && containsOpposingTeam(potentialMove, for: piece.team) {
            moves.append(potentialMove)
        }
        return moves
    }
    private func rookMoves(from: Coordinates, forPiece piece: ChessPiece) -> [Coordinates] {
        var moves: [Coordinates] = []
        
        var potentialMove = Coordinates(from.row+1, from.col)
        while isValidTile(potentialMove) && isEmptyTile(potentialMove) {
            moves.append(potentialMove)
            potentialMove.row += 1
        }
        if isValidTile(potentialMove) && containsOpposingTeam(potentialMove, for: piece.team) {
            moves.append(potentialMove)
        }
        
        potentialMove = Coordinates(from.row-1, from.col)
        while isValidTile(potentialMove) && isEmptyTile(potentialMove) {
            moves.append(potentialMove)
            potentialMove.row -= 1
        }
        if isValidTile(potentialMove) && containsOpposingTeam(potentialMove, for: piece.team) {
            moves.append(potentialMove)
        }
        
        potentialMove = Coordinates(from.row, from.col+1)
        while isValidTile(potentialMove) && isEmptyTile(potentialMove) {
            moves.append(potentialMove)
            potentialMove.col += 1
        }
        if isValidTile(potentialMove) && containsOpposingTeam(potentialMove, for: piece.team) {
            moves.append(potentialMove)
        }
        
        potentialMove = Coordinates(from.row, from.col-1)
        while isValidTile(potentialMove) && isEmptyTile(potentialMove) {
            moves.append(potentialMove)
            potentialMove.col -= 1
        }
        if isValidTile(potentialMove) && containsOpposingTeam(potentialMove, for: piece.team) {
            moves.append(potentialMove)
        }
        
        return moves
    }
    private func knightMoves(from location: Coordinates, forPiece piece: ChessPiece) -> [Coordinates] {
        allPotentialKnightMoves(from: location).filter { isEmptyTile($0) || containsOpposingTeam($0, for: piece.team) }
    }
    private func allPotentialKnightMoves(from: Coordinates) -> [Coordinates] {
        var potentialMoves: [Coordinates] = []
        
        potentialMoves.append(Coordinates(from.row+1, from.col+2))
        potentialMoves.append(Coordinates(from.row+2, from.col+1))
        
        potentialMoves.append(Coordinates(from.row+1, from.col-2))
        potentialMoves.append(Coordinates(from.row+2, from.col-1))
        
        potentialMoves.append(Coordinates(from.row-1, from.col+2))
        potentialMoves.append(Coordinates(from.row-2, from.col+1))
        
        potentialMoves.append(Coordinates(from.row-1, from.col-2))
        potentialMoves.append(Coordinates(from.row-2, from.col-1))
        
        return potentialMoves.filter{ isValidTile($0) }
    }
    private func bishopMoves(from: Coordinates, forPiece piece: ChessPiece) -> [Coordinates] {
        var moves: [Coordinates] = []
        
        var potentialMove = Coordinates(from.row+1, from.col+1)
        while isValidTile(potentialMove) && isEmptyTile(potentialMove) {
            moves.append(potentialMove)
            potentialMove.row += 1
            potentialMove.col += 1
        }
        if isValidTile(potentialMove) && containsOpposingTeam(potentialMove, for: piece.team) {
            moves.append(potentialMove)
        }
        
        potentialMove = Coordinates(from.row-1, from.col-1)
        while isValidTile(potentialMove) && isEmptyTile(potentialMove) {
            moves.append(potentialMove)
            potentialMove.row -= 1
            potentialMove.col -= 1
        }
        if isValidTile(potentialMove) && containsOpposingTeam(potentialMove, for: piece.team) {
            moves.append(potentialMove)
        }
        
        potentialMove = Coordinates(from.row-1, from.col+1)
        while isValidTile(potentialMove) && isEmptyTile(potentialMove) {
            moves.append(potentialMove)
            potentialMove.row -= 1
            potentialMove.col += 1
        }
        if isValidTile(potentialMove) && containsOpposingTeam(potentialMove, for: piece.team) {
            moves.append(potentialMove)
        }
        
        potentialMove = Coordinates(from.row+1, from.col-1)
        while isValidTile(potentialMove) && isEmptyTile(potentialMove) {
            moves.append(potentialMove)
            potentialMove.row += 1
            potentialMove.col -= 1
        }
        if isValidTile(potentialMove) && containsOpposingTeam(potentialMove, for: piece.team) {
            moves.append(potentialMove)
        }
        
        return moves
    }
    private func queenMoves(from: Coordinates, forPiece piece: ChessPiece) -> [Coordinates] {
        var moves: [Coordinates] = []
        
        moves.append(contentsOf: rookMoves(from: from, forPiece: piece))
        moves.append(contentsOf: bishopMoves(from: from, forPiece: piece))
        
        return moves
    }
    private func kingMoves(from: Coordinates, forPiece piece: ChessPiece) -> [Coordinates] {
        var moves: [Coordinates] = []
        
        for potentialMove in adjacentTiles(from) {
            if (isEmptyTile(potentialMove) || containsOpposingTeam(potentialMove, for: piece.team)) && !underAttack(at: potentialMove, ignoring: from, byTeam: opposingTeam(of: piece.team)) {
                moves.append(potentialMove)
            }
        }
        
        return moves
    }
    private func adjacentTiles(_ location: Coordinates) -> [Coordinates] {
        var adjacents: [Coordinates] = []
        
        adjacents.append(Coordinates(location.row+1, location.col-1))
        adjacents.append(Coordinates(location.row+1, location.col))
        adjacents.append(Coordinates(location.row+1, location.col+1))
        
        adjacents.append(Coordinates(location.row, location.col-1))
        adjacents.append(Coordinates(location.row, location.col+1))
        
        adjacents.append(Coordinates(location.row-1, location.col-1))
        adjacents.append(Coordinates(location.row-1, location.col))
        adjacents.append(Coordinates(location.row-1, location.col+1))
        
        return adjacents.filter { isValidTile($0) }
    }
    private func underAttack(at location: Coordinates, ignoring: Coordinates? = nil, byTeam team: Team) -> Bool {
        // check for knights
        for pAttackerPosition in allPotentialKnightMoves(from: location) {
            if boardContains(team, [.knight], at: pAttackerPosition) {
                return true
            }
        }
        // check for pawns
        // check diagonals
        var pAttackerPosition = firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: team == .white ? 1 : -1, colIncrement: 1)
        if let atkPosition = pAttackerPosition, boardContains(team, [.bishop, .queen], at: atkPosition) || (boardContains(team, [.pawn, .king], at: atkPosition) && areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: team == .white ? 1 : -1, colIncrement: -1)
        if let atkPosition = pAttackerPosition, boardContains(team, [.bishop, .queen], at: atkPosition) || (boardContains(team, [.pawn, .king], at: atkPosition) && areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: team == .white ? -1 : 1, colIncrement: -1)
        if let atkPosition = pAttackerPosition, boardContains(team, [.bishop, .queen], at: atkPosition) || (boardContains(team, [.king], at: atkPosition) && areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: team == .white ? -1 : 1, colIncrement: 1)
        if let atkPosition = pAttackerPosition, boardContains(team, [.bishop, .queen], at: atkPosition) || (boardContains(team, [.king], at: atkPosition) && areAdjacent(location, atkPosition)){
            return true
        }
        
        // check straights
        pAttackerPosition = firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: 1, colIncrement: 0)
        if let atkPosition = pAttackerPosition, boardContains(team, [.rook, .queen], at: atkPosition) || (boardContains(team, [.king], at: atkPosition) && areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: -1, colIncrement: 0)
        if let atkPosition = pAttackerPosition, boardContains(team, [.rook, .queen], at: atkPosition) || (boardContains(team, [.king], at: atkPosition) && areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: 0, colIncrement: 1)
        if let atkPosition = pAttackerPosition, boardContains(team, [.rook, .queen], at: atkPosition) || (boardContains(team, [.king], at: atkPosition) && areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: 0, colIncrement: -1)
        if let atkPosition = pAttackerPosition, boardContains(team, [.rook, .queen], at: atkPosition) || (boardContains(team, [.king], at: atkPosition) && areAdjacent(location, atkPosition)) {
            return true
        }
        
        return false
    }
    
    private func isValidTile(_ loc: Coordinates) -> Bool {
        loc.row < Chess.boardSize && loc.row >= 0 && loc.col < Chess.boardSize && loc.col >= 0
    }
    private func isEmptyTile(_ loc: Coordinates) -> Bool {
        board[loc.row][loc.col].chessPiece == nil
    }
    private func containsOpposingTeam(_ loc: Coordinates, for team: Team) -> Bool {
        guard let piece =  board[loc.row][loc.col].chessPiece else {
            return false
        }
        return piece.team != team
    }
    private func boardContains(_ team: Team, _ pieceTypes: [PieceType], at location: Coordinates) -> Bool {
        guard let piece = board[location.row][location.col].chessPiece else {
            return false
        }
        if piece.team != team {
            return false
        }
        for searchPieceType in pieceTypes {
            if piece.pieceType == searchPieceType {
                return true
            }
        }
        return false
    }
    private func opposingTeam(of team: Team) -> Team {
        switch team {
        case .black:
            return .white
        case .white:
            return .black
        }
    }
    private func firstPieceInPath(from location: Coordinates, ignoring: Coordinates? = nil, rowIncrement: Int, colIncrement: Int) -> Coordinates? {
        var next = Coordinates(location.row + rowIncrement, location.col + colIncrement)
        while isValidTile(next) && isEmptyTile(next) || (next == ignoring) {
            next.row += rowIncrement
            next.col += colIncrement
        }
        return isValidTile(next) && !isEmptyTile(next) && next != ignoring ? next : nil
    }
    private func areAdjacent(_ a: Coordinates, _ b: Coordinates) -> Bool {
        abs(a.row - b.row) < 2 && abs(a.col - b.col) < 2
    }
}
