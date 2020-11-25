//
//  ChessRules.swift
//  Chess
//
//  Created by Mario Machado on 2020-11-22.
//

import Foundation

struct ChessRules {
    static let increments = [1, -1]
    
    static func pawnMoves(from: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]]) -> [Coordinates] {
        var moves: [Coordinates] = []
        
        var potentialMove = Coordinates(piece.team == .white ? from.row-1 : from.row+1, from.col)
        if board.isValidTile(potentialMove) && board.isEmptyTile(potentialMove) {
            moves.append(potentialMove)
        }
        
        // Hack: moves.count > 0 means first square is empty since it was added as a good move
        // Meaning the order of if's here is important, this should be second
        //
        // Note: !piece.hasMoved will ensure it is always from starting pawn row, index ob is impossible
        potentialMove = Coordinates(piece.team == .white ? from.row-2 : from.row+2, from.col)
        if moves.count > 0 && !piece.hasMoved && board.isEmptyTile(potentialMove){
            moves.append(potentialMove)
        }
        
        potentialMove = Coordinates(piece.team == .white ? from.row-1 : from.row+1, from.col+1)
        if board.isValidTile(potentialMove) && board.containsOpposingTeam(potentialMove, of: piece.team) {
            moves.append(potentialMove)
        }
        
        potentialMove = Coordinates(piece.team == .white ? from.row-1 : from.row+1, from.col-1)
        if board.isValidTile(potentialMove) && board.containsOpposingTeam(potentialMove, of: piece.team) {
            moves.append(potentialMove)
        }
        return moves
    }
    
    static func rookMoves(from: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]]) -> [Coordinates] {
        var moves: [Coordinates] = []
        var potentialMove: Coordinates
        
        for increment in increments {
            potentialMove = Coordinates(from.row + increment, from.col)
            while board.isValidTile(potentialMove) && board.isEmptyTile(potentialMove) {
                moves.append(potentialMove)
                potentialMove.row += increment
            }
            if board.isValidTile(potentialMove) && board.containsOpposingTeam(potentialMove, of: piece.team) {
                moves.append(potentialMove)
            }
        }
        
        for increment in increments {
            potentialMove = Coordinates(from.row, from.col + increment)
            while board.isValidTile(potentialMove) && board.isEmptyTile(potentialMove) {
                moves.append(potentialMove)
                potentialMove.col += increment
            }
            if board.isValidTile(potentialMove) && board.containsOpposingTeam(potentialMove, of: piece.team) {
                moves.append(potentialMove)
            }
        }
        
        return moves
    }
    
    static func knightMoves(from location: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]]) -> [Coordinates] {
        allPotentialKnightMoves(from: location, on: board).filter { board.isEmptyTile($0) || board.containsOpposingTeam($0, of: piece.team) }
    }
    
    static func allPotentialKnightMoves(from: Coordinates, on board: [[ChessTile]]) -> [Coordinates] {
        var potentialMoves: [Coordinates] = []
        
        potentialMoves.append(Coordinates(from.row+1, from.col+2))
        potentialMoves.append(Coordinates(from.row+2, from.col+1))
        
        potentialMoves.append(Coordinates(from.row+1, from.col-2))
        potentialMoves.append(Coordinates(from.row+2, from.col-1))
        
        potentialMoves.append(Coordinates(from.row-1, from.col+2))
        potentialMoves.append(Coordinates(from.row-2, from.col+1))
        
        potentialMoves.append(Coordinates(from.row-1, from.col-2))
        potentialMoves.append(Coordinates(from.row-2, from.col-1))
        
        return potentialMoves.filter{ board.isValidTile($0) }
    }
    
    static func bishopMoves(from: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]]) -> [Coordinates] {
        var moves: [Coordinates] = []
        
        var potentialMove = Coordinates(from.row+1, from.col+1)
        while board.isValidTile(potentialMove) && board.isEmptyTile(potentialMove) {
            moves.append(potentialMove)
            potentialMove.row += 1
            potentialMove.col += 1
        }
        if board.isValidTile(potentialMove) && board.containsOpposingTeam(potentialMove, of: piece.team) {
            moves.append(potentialMove)
        }
        
        potentialMove = Coordinates(from.row-1, from.col-1)
        while board.isValidTile(potentialMove) && board.isEmptyTile(potentialMove) {
            moves.append(potentialMove)
            potentialMove.row -= 1
            potentialMove.col -= 1
        }
        if board.isValidTile(potentialMove) && board.containsOpposingTeam(potentialMove, of: piece.team) {
            moves.append(potentialMove)
        }
        
        potentialMove = Coordinates(from.row-1, from.col+1)
        while board.isValidTile(potentialMove) && board.isEmptyTile(potentialMove) {
            moves.append(potentialMove)
            potentialMove.row -= 1
            potentialMove.col += 1
        }
        if board.isValidTile(potentialMove) && board.containsOpposingTeam(potentialMove, of: piece.team) {
            moves.append(potentialMove)
        }
        
        potentialMove = Coordinates(from.row+1, from.col-1)
        while board.isValidTile(potentialMove) && board.isEmptyTile(potentialMove) {
            moves.append(potentialMove)
            potentialMove.row += 1
            potentialMove.col -= 1
        }
        if board.isValidTile(potentialMove) && board.containsOpposingTeam(potentialMove, of: piece.team) {
            moves.append(potentialMove)
        }
        
        return moves
    }
    static func queenMoves(from: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]]) -> [Coordinates] {
        var moves: [Coordinates] = []
        
        moves.append(contentsOf: rookMoves(from: from, forPiece: piece, on: board))
        moves.append(contentsOf: bishopMoves(from: from, forPiece: piece, on: board))
        
        return moves
    }
    static func kingMoves(from: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]]) -> [Coordinates] {
        var moves: [Coordinates] = []
        
        for potentialMove in board.adjacentTiles(from) {
            if (board.isEmptyTile(potentialMove) || board.containsOpposingTeam(potentialMove, of: piece.team)) && !underAttack(at: potentialMove, ignoring: from, byTeam: opposingTeam(of: piece.team), on: board) {
                moves.append(potentialMove)
            }
        }
        
        return moves
    }
    
    static func underAttack(at location: Coordinates, ignoring: Coordinates? = nil, byTeam team: Team, on board: [[ChessTile]]) -> Bool {
        // check for knights
        for pAttackerPosition in allPotentialKnightMoves(from: location, on: board) {
            if board.contains(team, [.knight], at: pAttackerPosition) {
                return true
            }
        }
        // check for pawns
        // check diagonals
        var pAttackerPosition = board.firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: team == .white ? 1 : -1, colIncrement: 1)
        if let atkPosition = pAttackerPosition, board.contains(team, [.bishop, .queen], at: atkPosition) || (board.contains(team, [.pawn, .king], at: atkPosition) && areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = board.firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: team == .white ? 1 : -1, colIncrement: -1)
        if let atkPosition = pAttackerPosition, board.contains(team, [.bishop, .queen], at: atkPosition) || (board.contains(team, [.pawn, .king], at: atkPosition) && areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = board.firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: team == .white ? -1 : 1, colIncrement: -1)
        if let atkPosition = pAttackerPosition, board.contains(team, [.bishop, .queen], at: atkPosition) || (board.contains(team, [.king], at: atkPosition) && areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = board.firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: team == .white ? -1 : 1, colIncrement: 1)
        if let atkPosition = pAttackerPosition, board.contains(team, [.bishop, .queen], at: atkPosition) || (board.contains(team, [.king], at: atkPosition) && areAdjacent(location, atkPosition)){
            return true
        }
        
        // check straights
        pAttackerPosition = board.firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: 1, colIncrement: 0)
        if let atkPosition = pAttackerPosition, board.contains(team, [.rook, .queen], at: atkPosition) || (board.contains(team, [.king], at: atkPosition) && areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = board.firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: -1, colIncrement: 0)
        if let atkPosition = pAttackerPosition, board.contains(team, [.rook, .queen], at: atkPosition) || (board.contains(team, [.king], at: atkPosition) && areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = board.firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: 0, colIncrement: 1)
        if let atkPosition = pAttackerPosition, board.contains(team, [.rook, .queen], at: atkPosition) || (board.contains(team, [.king], at: atkPosition) && areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = board.firstPieceInPath(from: location, ignoring: ignoring, rowIncrement: 0, colIncrement: -1)
        if let atkPosition = pAttackerPosition, board.contains(team, [.rook, .queen], at: atkPosition) || (board.contains(team, [.king], at: atkPosition) && areAdjacent(location, atkPosition)) {
            return true
        }
        
        return false
    }
    
    private static func opposingTeam(of team: Team) -> Team {
        switch team {
        case .black:
            return .white
        case .white:
            return .black
        }
    }
    
    private static func areAdjacent(_ a: Coordinates, _ b: Coordinates) -> Bool {
        abs(a.row - b.row) < 2 && abs(a.col - b.col) < 2
    }
}
