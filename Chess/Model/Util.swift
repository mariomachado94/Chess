//
//  Util.swift
//  Chess
//
//  Created by Mario Machado on 2020-11-26.
//

import Foundation

struct Util {
    static func opposingTeam(of team: Team) -> Team {
        switch team {
        case .black:
            return .white
        case .white:
            return .black
        }
    }
    
    static func areAdjacent(_ a: Coordinates, _ b: Coordinates) -> Bool {
        abs(a.row - b.row) < 2 && abs(a.col - b.col) < 2
    }
}
