require_relative 'board.rb'
require_relative 'pieces.rb'

class ChessRunner
    attr_accessor :board
    def initialize
        @board = ChessBoard.new
        @activeplayer = :white
        @inactiveplayer = :black
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
            @board.place_piece(Rook.new(:black),[0,row])
            @board.place_piece(Rook.new(:black),[7, row])
            @board.place_piece(Knight.new(:black),[1,row])
            @board.place_piece(Knight.new(:black),[6,row])
            @board.place_piece(Bishop.new(:black),[2,row])
            @board.place_piece(Bishop.new(:black),[5,row])
            @board.place_piece(King.new(:black),[4,row])
            @board.place_piece(Queen.new(:black),[3,row])
        elsif color == :white
            @board.place_piece(Rook.new(:white),[0,row])
            @board.place_piece(Rook.new(:white),[7, row])
            @board.place_piece(Knight.new(:white),[1,row])
            @board.place_piece(Knight.new(:white),[6,row])
            @board.place_piece(Bishop.new(:white),[2,row])
            @board.place_piece(Bishop.new(:white),[5,row])
            @board.place_piece(King.new(:white),[4,row])
            @board.place_piece(Queen.new(:white),[3,row])
        end
    end

    def play
        until @board.game_over?
            draw_board
            move = get_move(@activeplayer)
            @board.execute_move(move)
            promo = promotable_pawn
            if promo
                @board.place_piece(select_promotion(@activeplayer),pos)
            end
            if @board.checkmate?(@inactiveplayer)
                puts "Checkmate for #{@activeplayer}"
            elsif @board.check?(@inactiveplayer)
                puts "Check for #{@activeplayer}"
            end
            self.swap_activeplayer
        end
    end

    def promotable_pawn
        @board.each do |piece|
            if piece.class == Pawn
                index = @board.index(piece)
                pos = [index % 8, index / 8]
                return pos if pos[1] == 7 && piece.color == :white
                return pos if pos[1] == 0 && piece.color == :black
            end
        end
        nil
    end

    def select_promotion(color)
        puts "Select a unit to promote pawn to Queen (Q) Bishop (B) Rook (R) Knight (N)"
        unit = gets.chomp
        loop do
            if unit.match?(/^[QBRN]$/)
                case unit
                when Q
                    return Queen.new(color)
                when B
                    return Bishop.new(color)
                when R
                    return Rook.new(color)
                when N
                    return Knight.new(color)
                end
            end
            puts "Invalid unit, try again:"
            unit = gets.chomp            
        end
    end

    def swap_activeplayer
        @activeplayer, @inactiveplayer = @inactiveplayer, @activeplayer
    end

    def get_move(player)
        puts "Player #{player} please select your move:"
        move = gets.chomp
        loop do
            if move.match?(/[KQRBPN][a-h][1-8][a-h][1-8]/)
                letter = move[0]
                start = ChessBoard.translate_rank_file(move[1..2])
                dest = ChessBoard.translate_rank_file(move[3..4])
                piece = @board.pos_piece(start)
                if piece && piece.letter == letter && piece.color == player && piece.destinations(@board, start).include?(dest)
                    return [start,dest]
                end
            end
            puts "Invalid move, please try again:"
            move = gets.chomp
        end
    end
end