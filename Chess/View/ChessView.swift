//
//  ContentView.swift
//  Chess
//
//  Created by Mario Machado on 2020-11-10.
//

import SwiftUI

struct ChessView: View {
    @ObservedObject var chessViewModel: ChessViewModel = ChessViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Button("New Game", action: {
                    withAnimation(.linear) {
                        chessViewModel.newGame()
                    }
                })
                Board(size: geometry.size).environmentObject(chessViewModel)
            }
        }
    }
}

struct Board: View {
    @EnvironmentObject var chessViewModel: ChessViewModel
    
    let tilesPerRow = 8
    var size: CGSize
    var tileSize: CGFloat {
        min(size.width, size.height)/CGFloat(tilesPerRow)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<tilesPerRow) { row in
                HStack(spacing: 0) {
                    ForEach(0..<tilesPerRow) { col in
                        ZStack {
                            Rectangle().foregroundColor(tileColor(row, col)).frame(width: tileSize, height: tileSize)
                            ChessPieceV(chessPiece: chessViewModel.chessBoard[row][col])
                        }.onTapGesture {
                            withAnimation(.linear) {
                                chessViewModel.select(row, col)
                            }
                        }
                    }
                }
            }
        }.border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
    }
    
    static let selectedColor = Color.yellow
    static let primaryTileColor = Color.green
    static let secondaryTileColor = Color.gray
    func tileColor(_ row: Int, _ col: Int) -> Color {
        if chessViewModel.isSelected(row, col) {
            return Board.selectedColor
        }
        else if row % 2 == 0 {
            if col % 2 == 0 {
                return Board.primaryTileColor
            }
            else {
                return Board.secondaryTileColor
            }
        }
        else {
            if col % 2 == 0 {
                return Board.secondaryTileColor
            }
            else {
                return Board.primaryTileColor
            }
        }
    }
}

struct ChessPieceV: View {
    var chessPiece: ChessPiece?
    
    static let pieceTypeToImgName: [PieceType : String] = [.pawn:"triangle.fill", .rook: "hexagon.fill", .knight: "shield.fill", .bishop: "rhombus.fill", .queen: "seal.fill", .king: "crown.fill",]
    var body: some View {
        if let chessPiece = self.chessPiece {
            Image(systemName: ChessPieceV.pieceTypeToImgName[chessPiece.pieceType] ?? "circle.fill")
                .foregroundColor(chessPiece.team == .white ? Color.white : Color.black)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChessView()
    }
}
