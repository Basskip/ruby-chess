class ChessBoard
    WIDTH = 8
    HEIGHT = 8

    def initialize
        @board = Array.new(8*8)
    end

    def place_piece(piece, pos)
        @board[self.class.xy_to_flat(pos[0],pos[1])] = piece
    end

    def is_empty?
        @board.empty?
    end

    def xy_free?(x,y)
        @board[self.class.xy_to_flat(x,y)] == nil
    end

    def pos_free?(pos)
        xy_free?(pos[0],pos[1])
    end

    def pos_piece(pos)
        @board[self.class.xy_to_flat(pos[0],pos[1])]
    end

    def xy_piece(x,y)
        @board[self.class.xy_to_flat(x,y)]
    end

    def index(piece)
        @board.index(piece)
    end

    def checkmate?(color)
        @board.each do |piece|
            if piece && piece.class == King && piece.color == color
                index = @board.index(piece)
                pos = [index % HEIGHT, index / HEIGHT]
                return pos_checked?(pos, color) && piece.destinations(self, pos) == []
            end
        end
        false
    end

    def check?(color)
        @board.each do |piece|
            if piece && piece.class == King && piece.color == color
                index = @board.index(piece)
                pos = [index % HEIGHT, index / HEIGHT]
                return pos_checked?(pos, color)
            end
        end
        false
    end

    def game_over?
        return checkmate?(:white) || checkmate?(:black)
    end

    def each
        @board.each do |pos|
            yield(pos)
        end
    end

    def pos_checked?(pos, side)
        WIDTH.times do |x|
            HEIGHT.times do |y|
                piece = self.pos_piece([x,y])
                if piece && piece.color != side
                    return true if piece.capture_spaces(self,[x,y]).include?(pos)
                end
            end
        end
        false
    end

    def clear_passants
        @board.each do |piece|
            if piece.class == Pawn
                piece.passant_capturable= false
                piece.passant_pos= nil
            end
        end
    end
    
    def self.xy_to_flat(x,y)
        y*8 + x
    end

    def self.translate_rank_file(rf)
        rank = rf[0]
        x = rank.ord - 'a'.ord
        y = rf[1].to_i - 1
        return [x,y]
    end

    def self.valid_move(pos, move)
        return false if pos[0] + move[0] > WIDTH - 1 || pos[0] + move[0] < 0
        return false if pos[1] + move[1] > HEIGHT - 1 || pos[1] + move[1] < 1
        true
    end

    def self.on_board?(pos)
        return false if pos[0] > WIDTH - 1 || pos[0] < 0
        return false if pos[1] > HEIGHT - 1 || pos[1] < 0
        true
    end

    def printable_board
        result = ""
        (HEIGHT - 1).downto(0) do |y|
            row = ""
            WIDTH.times do |x|
                if pos_piece([x,y])
                    row << pos_piece([x,y]).symbol
                else
                    row << " "
                end
            end
            row << "\n"
            result << row
        end
        result
    end
end