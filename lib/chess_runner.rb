require_relative 'board.rb'
require_relative 'pieces.rb'
require_relative 'saving.rb'


class ChessRunner
    include Saving
    attr_accessor :board
    def initialize
        self.setup_game
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

    def setup_game
        @board = ChessBoard.new
        @activeplayer = :white
        @inactiveplayer = :black
        place_others(:white, 0)
        place_pawns(:white, 1)
        place_pawns(:black, 6)
        place_others(:black, 7)
    end

    def start
        puts "Welcome to chess, select an option to start:"
        puts "1 - Start a new game"
        puts "2 - Load a game from file"
        puts "3 - Quit"
        selection = get_selection
        if selection == "1"
            play
        elsif selection == "2"
            show_saves
            load_from_file(select_save)
            play
        elsif selection == "3"
            exit
        end
    end

    def get_selection
        print "Your selection: "
        input = ""

        loop do
            input = gets.chomp
            if input.match?(/[1-3]/)
                break
            else 
                print "Invalid selection try again:"
            end
        end
        input
    end

    def play
        until @board.game_over?(@activeplayer)
            draw_board
            move = get_move(@activeplayer)
            until move != "save"
                if move == "save"
                    save(self.get_filename)
                end
                move = get_move(@activeplayer)
            end
            if move == "exit"
                break
            end
            @board.execute_move(move)
            promo = promotable_pawn
            if promo
                @board.place_piece(select_promotion(@activeplayer),pos)
            end
            if @board.stalemate?(@inactiveplayer) 
                puts "The #{@inactiveplayer} player is stalemated"
            elsif @board.checkmate?(@inactiveplayer)
                puts "Checkmate for #{@activeplayer}"
            elsif @board.check?(@inactiveplayer)
                puts "Check for #{@activeplayer}"
            end
            self.swap_activeplayer
        end
        self.setup_game
        self.start
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
                if piece && piece.letter == letter && piece.color == player && piece.destinations_without_check(@board, start).include?(dest)
                    return [start,dest]
                end
            elsif move == "save" || move == "exit"
                return move
            end
            puts "Invalid move, please try again:"
            move = gets.chomp
        end
    end

    def to_yaml
        YAML.dump ({
            :board => @board,
            :activeplayer => @activeplayer,
            :inactiveplayer => @inactiveplayer
        })
    end

    def load_from_yaml(string)
        data = YAML.load(string)
        @board = data[:board]
        @activeplayer = data[:activeplayer]
        @inactiveplayer = data[:inactiveplayer]
    end
end