//
//  ContentView.swift
//  Chess
//
//  Created by Mario Machado on 2020-11-10.
//

import SwiftUI

struct ChessView: View {
    @ObservedObject var chessGame: ChessGame = ChessGame()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Text("White: \(chessGame.whiteTurns)")
                    Spacer()
                    Text((chessGame.whosTurn == .white) ? "WHITE" : "BLACK").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Text("Black: \(chessGame.blackTurns)")
                }.padding()
                Board(size: geometry.size).environmentObject(chessGame)
                Spacer()
                Button("New Game", action: {
                    withAnimation(.linear) {
                        chessGame.newGame()
                    }
                })
            }
        }
    }
}

struct Board: View {
    @EnvironmentObject var chessViewModel: ChessGame
    
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
                        TileView(tile: chessViewModel.board[row][col], size: tileSize)
                    }
                }
            }
        }.border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
    }
}

struct TileView: View {
    @EnvironmentObject var chessViewModel: ChessGame
    
    var tile: ChessTile
    var size: CGFloat
    
    var body: some View {
        ZStack {
            Rectangle().foregroundColor(tileColor).frame(width: size, height: size)
            ChessPieceView(chessPiece: tile.chessPiece)
        }.onTapGesture {
            withAnimation(.linear) {
                chessViewModel.select(tile.row, tile.col)
            }
        }
    }
    
    static let highlightColor = Color.yellow
    static let primaryTileColor = Color.green
    static let secondaryTileColor = Color.gray
    
    var tileColor: Color {
        if tile.highlight {
            return TileView.highlightColor
        }
        
        switch tile.tileType {
        case .primary:
            return TileView.primaryTileColor
        case .secondary:
            return TileView.secondaryTileColor
        }
    }
}

struct ChessPieceView: View {
    var chessPiece: ChessPiece?
    
    static let pieceTypeToImgName: [PieceType : String] = [.pawn:"triangle.fill", .rook: "hexagon.fill", .knight: "shield.fill", .bishop: "rhombus.fill", .queen: "seal.fill", .king: "crown.fill",]
    var body: some View {
        if let chessPiece = self.chessPiece {
            Image(systemName: ChessPieceView.pieceTypeToImgName[chessPiece.pieceType] ?? "circle.fill")
                .foregroundColor(chessPiece.team == .white ? Color.white : Color.black)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChessView()
    }
}
