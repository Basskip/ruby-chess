require_relative 'board.rb'
require_relative 'pieces.rb'

class ChessRunner
    def initialize
        @board = ChessBoard.new
        place_others(:white, 0)
        place_pawns(:white, 1)
        place_pawns(:black, 6)
        place_others(:black, 7)
    end

    def place_pawns(color, row)
        marker = (color == :black ? "\u{265F}" : "\u{2659}")
        8.times do |x|
            @board.place_piece(Pawn.new(color,marker),[x,row])
        end
    end

    def draw_board
        puts @board.printable_board
    end

    def place_others(color, row)
        if color == :black
            @board.place_piece(Rook.new(:black,"\u{265C}"),[0,row])
            @board.place_piece(Rook.new(:black,"\u{265C}"),[7, row])
            @board.place_piece(Knight.new(:black,"\u{265E}"),[1,row])
            @board.place_piece(Knight.new(:black,"\u{265E}"),[6,row])
            @board.place_piece(Bishop.new(:black,"\u{265D}"),[2,row])
            @board.place_piece(Bishop.new(:black,"\u{265D}"),[5,row])
            @board.place_piece(King.new(:black,"\u{265A}"),[4,row])
            @board.place_piece(Queen.new(:black,"\u{265B}"),[3,row])
        elsif color == :white
            @board.place_piece(Rook.new(:white,"\u{2656}"),[0,row])
            @board.place_piece(Rook.new(:white,"\u{2656}"),[7, row])
            @board.place_piece(Knight.new(:white,"\u{2658}"),[1,row])
            @board.place_piece(Knight.new(:white,"\u{2658}"),[6,row])
            @board.place_piece(Bishop.new(:white,"\u{2657}"),[2,row])
            @board.place_piece(Bishop.new(:white,"\u{2657}"),[5,row])
            @board.place_piece(King.new(:white,"\u{2654}"),[4,row])
            @board.place_piece(Queen.new(:white,"\u{2655}"),[3,row])
        end
    end

    def play
        # get the current player's move
        # make sure the move is valid
        # execute the move
        # check for: check, checkmate and promotions
    end
end