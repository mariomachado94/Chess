//
//  ChessRules.swift
//  Chess
//
//  Created by Mario Machado on 2020-11-22.
//

import Foundation

struct Movement {
    struct Incrementer {
        let rowInc: Int
        let colInc: Int
    }
    
    static let increments = [1, -1]
    static let diagnolIncrementers = [Incrementer(rowInc: 1, colInc: 1), Incrementer(rowInc: -1, colInc: -1), Incrementer(rowInc: 1, colInc: -1), Incrementer(rowInc: -1, colInc: 1)]
    static let straightIncrementers = [Incrementer(rowInc: 1, colInc: 0), Incrementer(rowInc: -1, colInc: 0), Incrementer(rowInc: 0, colInc: -1), Incrementer(rowInc: 0, colInc: 1)]
    
    static func pawnMoves(from: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]], lastMove: Move?) -> [Move] {
        var moves: [Move] = []
        
        var potentialMoveTo = Coordinates(piece.team == .white ? from.row-1 : from.row+1, from.col)
        if board.isValidTile(potentialMoveTo) && board.isEmptyTile(potentialMoveTo) {
            moves.append(Move(from: from, to: potentialMoveTo))
        }
        
        // Hack: moves.count > 0 means first square is empty since it was added as a good move
        // Meaning the order of if's here is important, this should be second
        //
        // Note: !piece.hasMoved will ensure it is always from starting pawn row, index ob is impossible
        potentialMoveTo = Coordinates(piece.team == .white ? from.row-2 : from.row+2, from.col)
        if moves.count > 0 && !piece.hasMoved && board.isEmptyTile(potentialMoveTo){
            moves.append(Move(from: from, to: potentialMoveTo))
        }
        
        // Check attack diagnols
        for colIncrement in increments {
            potentialMoveTo = Coordinates(piece.team == .white ? from.row-1 : from.row+1, from.col+colIncrement)
            if board.isValidTile(potentialMoveTo) {
                if board.containsOpposingTeam(potentialMoveTo, of: piece.team) {
                    moves.append(Move(from: from, to: potentialMoveTo, captures: board[potentialMoveTo].chessPiece!))
                }
                else if enPassant(at: potentialMoveTo, onBoard: board, lastMove: lastMove) {
                    moves.append(Move(from: from, to: potentialMoveTo, captures: board[lastMove!.to].chessPiece!, captureLocation: lastMove!.to))
                }
            }
        }
        
        return moves
    }
    
    private static func enPassant(at: Coordinates, onBoard board: [[ChessTile]], lastMove: Move?) -> Bool {
        guard let lastMove = lastMove, let lastPiece = board[lastMove.to].chessPiece, lastPiece.pieceType == .pawn else {
            return false
        }
        
        if lastMove.to.col == at.col && abs(lastMove.to.row - lastMove.from.row) == 2 {
            let enPassantLocation = lastPiece.team == .white ? Coordinates(lastMove.from.row - 1, lastMove.from.col) : Coordinates(lastMove.from.row + 1, lastMove.from.col)
            return at == enPassantLocation
        }
        
        return false
    }
    
    static func rookMoves(from: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]]) -> [Move] {
        var moves: [Move] = []
        var potentialMoveTo: Coordinates
        
        for inc in straightIncrementers {
            potentialMoveTo = Coordinates(from.row + inc.rowInc, from.col + inc.colInc)
            while board.isValidTile(potentialMoveTo) && board.isEmptyTile(potentialMoveTo) {
                moves.append(Move(from: from, to: potentialMoveTo))
                potentialMoveTo.row += inc.rowInc
                potentialMoveTo.col += inc.colInc
            }
            if board.isValidTile(potentialMoveTo) && board.containsOpposingTeam(potentialMoveTo, of: piece.team) {
                moves.append(Move(from: from, to: potentialMoveTo, captures: board[potentialMoveTo].chessPiece!))
            }
        }
        
        return moves
    }
    
    static func knightMoves(from location: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]]) -> [Move] {
        allPotentialKnightMoveTos(from: location, on: board).filter { board.isEmptyTile($0) || board.containsOpposingTeam($0, of: piece.team) }.map { board.isEmptyTile($0) ? Move(from: location, to: $0) : Move(from: location, to: $0, captures: board[$0].chessPiece!) }
        
    }
    
    static func allPotentialKnightMoveTos(from: Coordinates, on board: [[ChessTile]]) -> [Coordinates] {
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
    
    static func bishopMoves(from: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]]) -> [Move] {
        var moves: [Move] = []
        var potentialMoveTo: Coordinates
        
        for inc in diagnolIncrementers {
            potentialMoveTo = Coordinates(from.row+inc.rowInc, from.col+inc.colInc)
            while board.isValidTile(potentialMoveTo) && board.isEmptyTile(potentialMoveTo) {
                moves.append(Move(from: from, to: potentialMoveTo))
                potentialMoveTo.row += inc.rowInc
                potentialMoveTo.col += inc.colInc
            }
            if board.isValidTile(potentialMoveTo) && board.containsOpposingTeam(potentialMoveTo, of: piece.team) {
                moves.append(Move(from: from, to: potentialMoveTo, captures: board[potentialMoveTo].chessPiece!))
            }
        }
        
        return moves
    }
    static func queenMoves(from: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]]) -> [Move] {
        var moves: [Move] = []
        
        moves.append(contentsOf: rookMoves(from: from, forPiece: piece, on: board))
        moves.append(contentsOf: bishopMoves(from: from, forPiece: piece, on: board))
        
        return moves
    }
    static func kingMoves(from location: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]]) -> [Move] {
        var moves: [Move] = []
        
        for potentialMove in board.adjacentTiles(location) {
            if (board.isEmptyTile(potentialMove) || board.containsOpposingTeam(potentialMove, of: piece.team)) && !board.underAttack(at: potentialMove, ignoring: location, byTeam: Util.opposingTeam(of: piece.team)) {
                let move = board.isEmptyTile(potentialMove) ? Move(from: location, to: potentialMove) : Move(from: location, to: potentialMove, captures: board[potentialMove].chessPiece!)
                moves.append(move)
            }
        }
        
        moves.append(contentsOf: castleMoves(from: location, forPiece: piece, on: board))
        
        return moves
    }
    static func castleMoves(from location: Coordinates, forPiece piece: ChessPiece, on board: [[ChessTile]]) -> [Move] {
        var moves: [Move] = []
        if piece.hasMoved {
            return moves
        }
        
        if let fPieceLocation = board.firstPieceLocationInPath(from: location, rowIncrement: 0, colIncrement: 1), let rook = board[fPieceLocation].chessPiece {
            if rook.pieceType == .rook && !rook.hasMoved && board.pathNotUnderAttack(from: location, rowIncrement: 0, colIncrement: 1,
                                                                                     until: { $0 == Coordinates(location.row, location.col + 3) }, byTeam: Util.opposingTeam(of: piece.team)) {
                var fromToPairs = [location, Coordinates(location.row, location.col+2),
                    fPieceLocation, Coordinates(location.row, location.col+1)]
                moves.append(Move(fromToPairs: fromToPairs))
            }
        }
        if let fPieceLocation = board.firstPieceLocationInPath(from: location, rowIncrement: 0, colIncrement: -1), let rook = board[fPieceLocation].chessPiece {
            if rook.pieceType == .rook && !rook.hasMoved && board.pathNotUnderAttack(from: location, rowIncrement: 0, colIncrement: -1,
                                                                                     until: { $0 == Coordinates(location.row, location.col - 3) }, byTeam: Util.opposingTeam(of: piece.team)) {
                var fromToPairs = [location, Coordinates(location.row, location.col-2),
                    fPieceLocation, Coordinates(location.row, location.col-1)]
                moves.append(Move(fromToPairs: fromToPairs))
            }
        }
                
        return moves
    }
}
