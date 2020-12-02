//
//  Board.swift
//  Chess
//
//  Created by Mario Machado on 2020-11-22.
//

import Foundation

/*
 Extensions for a [[ChessTile]] Board
 */
extension Array where Element == Array<ChessTile> {
    func contains(_ team: Team, _ pieceTypes: [PieceType], at location: Coordinates) -> Bool {
        guard let piece = self[location.row][location.col].chessPiece else {
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
    
    subscript(_ location: Coordinates) -> ChessTile {
        self[location.row][location.col]
    }
    
    func containsOpposingTeam(_ location: Coordinates, of team: Team) -> Bool {
        guard let piece = self[location].chessPiece else {
            return false
        }
        return piece.team != team
    }
    
    func firstPieceLocationInPath(from location: Coordinates, ignoring: Coordinates? = nil, rowIncrement: Int, colIncrement: Int) -> Coordinates? {
        var next = Coordinates(location.row + rowIncrement, location.col + colIncrement)
        while isValidTile(next) && isEmptyTile(next) || (next == ignoring) {
            next.row += rowIncrement
            next.col += colIncrement
        }
        return isValidTile(next) && !isEmptyTile(next) && next != ignoring ? next : nil
    }
    
    func walkPath(from location: Coordinates, rowIncrement: Int, colIncrement: Int, checking: (Coordinates) -> Bool, until: (Coordinates) -> Bool) -> Bool {
        let nextLocation = Coordinates(location.row + rowIncrement, location.col + colIncrement)
        return walk(location: nextLocation, rowIncrement: rowIncrement, colIncrement: colIncrement, checking: checking, until: until)
    }
    private func walk(location: Coordinates, rowIncrement: Int, colIncrement: Int, checking: (Coordinates) -> Bool, until: (Coordinates) -> Bool) -> Bool {
        if !isValidTile(location) || until(location) {
            return true
        }
        else if !checking(location) {
            return false
        }
        else {
            let nextLocation = Coordinates(location.row + rowIncrement, location.col + colIncrement)
            return walk(location: nextLocation, rowIncrement: rowIncrement, colIncrement: colIncrement, checking: checking, until: until)
        }
    }
    
    func adjacentTiles(_ location: Coordinates) -> [Coordinates] {
        var adjacents: [Coordinates] = []
        
        adjacents.append(Coordinates(location.row+1, location.col-1))
        adjacents.append(Coordinates(location.row+1, location.col))
        adjacents.append(Coordinates(location.row+1, location.col+1))
        
        adjacents.append(Coordinates(location.row, location.col-1))
        adjacents.append(Coordinates(location.row, location.col+1))
        
        adjacents.append(Coordinates(location.row-1, location.col-1))
        adjacents.append(Coordinates(location.row-1, location.col))
        adjacents.append(Coordinates(location.row-1, location.col+1))
        
        return adjacents.filter { self.isValidTile($0) }
    }
    
    func isValidTile(_ location: Coordinates) -> Bool {
        location.row < self.count && location.row >= 0 && location.col < self[location.row].count && location.col >= 0
    }
    func isEmptyTile(_ location: Coordinates) -> Bool {
        self[location].chessPiece == nil
    }
    
    func pathNotUnderAttack(from location: Coordinates, rowIncrement: Int, colIncrement: Int, until: (Coordinates) -> Bool, byTeam team: Team) -> Bool {
        walkPath(from: location, rowIncrement: rowIncrement, colIncrement: colIncrement,
                 checking: { !self.underAttack(at: $0, byTeam: team) },
                 until: until)
    }
    func underAttack(at location: Coordinates, ignoring: Coordinates? = nil, byTeam team: Team) -> Bool {
        // check for knights
        for pAttackerPosition in Movement.allPotentialKnightMoves(from: location, on: self) {
            if self.contains(team, [.knight], at: pAttackerPosition) {
                return true
            }
        }
        // check for pawns
        // check diagonals
        var pAttackerPosition = self.firstPieceLocationInPath(from: location, ignoring: ignoring, rowIncrement: team == .white ? 1 : -1, colIncrement: 1)
        if let atkPosition = pAttackerPosition, self.contains(team, [.bishop, .queen], at: atkPosition) || (self.contains(team, [.pawn, .king], at: atkPosition) && Util.areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = self.firstPieceLocationInPath(from: location, ignoring: ignoring, rowIncrement: team == .white ? 1 : -1, colIncrement: -1)
        if let atkPosition = pAttackerPosition, self.contains(team, [.bishop, .queen], at: atkPosition) || (self.contains(team, [.pawn, .king], at: atkPosition) && Util.areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = self.firstPieceLocationInPath(from: location, ignoring: ignoring, rowIncrement: team == .white ? -1 : 1, colIncrement: -1)
        if let atkPosition = pAttackerPosition, self.contains(team, [.bishop, .queen], at: atkPosition) || (self.contains(team, [.king], at: atkPosition) && Util.areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = self.firstPieceLocationInPath(from: location, ignoring: ignoring, rowIncrement: team == .white ? -1 : 1, colIncrement: 1)
        if let atkPosition = pAttackerPosition, self.contains(team, [.bishop, .queen], at: atkPosition) || (self.contains(team, [.king], at: atkPosition) && Util.areAdjacent(location, atkPosition)){
            return true
        }
        
        // check straights
        pAttackerPosition = self.firstPieceLocationInPath(from: location, ignoring: ignoring, rowIncrement: 1, colIncrement: 0)
        if let atkPosition = pAttackerPosition, self.contains(team, [.rook, .queen], at: atkPosition) || (self.contains(team, [.king], at: atkPosition) && Util.areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = self.firstPieceLocationInPath(from: location, ignoring: ignoring, rowIncrement: -1, colIncrement: 0)
        if let atkPosition = pAttackerPosition, self.contains(team, [.rook, .queen], at: atkPosition) || (self.contains(team, [.king], at: atkPosition) && Util.areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = self.firstPieceLocationInPath(from: location, ignoring: ignoring, rowIncrement: 0, colIncrement: 1)
        if let atkPosition = pAttackerPosition, self.contains(team, [.rook, .queen], at: atkPosition) || (self.contains(team, [.king], at: atkPosition) && Util.areAdjacent(location, atkPosition)) {
            return true
        }
        
        pAttackerPosition = self.firstPieceLocationInPath(from: location, ignoring: ignoring, rowIncrement: 0, colIncrement: -1)
        if let atkPosition = pAttackerPosition, self.contains(team, [.rook, .queen], at: atkPosition) || (self.contains(team, [.king], at: atkPosition) && Util.areAdjacent(location, atkPosition)) {
            return true
        }
        
        return false
    }
}
