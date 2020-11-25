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
    
    func firstPieceInPath(from location: Coordinates, ignoring: Coordinates? = nil, rowIncrement: Int, colIncrement: Int) -> Coordinates? {
        var next = Coordinates(location.row + rowIncrement, location.col + colIncrement)
        while isValidTile(next) && isEmptyTile(next) || (next == ignoring) {
            next.row += rowIncrement
            next.col += colIncrement
        }
        return isValidTile(next) && !isEmptyTile(next) && next != ignoring ? next : nil
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
}
