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
    static func kingMoves(from location: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]]) -> [Coordinates] {
        var moves: [Coordinates] = []
        
        for potentialMove in board.adjacentTiles(location) {
            if (board.isEmptyTile(potentialMove) || board.containsOpposingTeam(potentialMove, of: piece.team)) && !board.underAttack(at: potentialMove, ignoring: location, byTeam: Util.opposingTeam(of: piece.team)) {
                moves.append(potentialMove)
            }
        }
        
        moves.append(contentsOf: castleMoves(from: location, forPiece: piece, on: board))
        
        return moves
    }
    static func castleMoves(from location: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]]) -> [Coordinates] {
        var moves: [Coordinates] = []
        if piece.hasMoved {
            return moves
        }
        
        if let fPieceLocation = board.firstPieceLocationInPath(from: location, rowIncrement: 0, colIncrement: 1), let rook = board[fPieceLocation].chessPiece {
            if rook.pieceType == .rook && !rook.hasMoved && board.pathNotUnderAttack(from: location, rowIncrement: 0, colIncrement: 1,
                                                                                     until: { $0 == Coordinates(location.row, location.col + 3) }, byTeam: Util.opposingTeam(of: piece.team)) {
                moves.append(Coordinates(location.row, location.col+2))
            }
        }
        if let fPieceLocation = board.firstPieceLocationInPath(from: location, rowIncrement: 0, colIncrement: -1), let rook = board[fPieceLocation].chessPiece {
            if rook.pieceType == .rook && !rook.hasMoved && board.pathNotUnderAttack(from: location, rowIncrement: 0, colIncrement: -1,
                                                                                     until: { $0 == Coordinates(location.row, location.col - 3) }, byTeam: Util.opposingTeam(of: piece.team)) {
                moves.append(Coordinates(location.row, location.col-2))
            }
        }
                
        return moves
    }
}
