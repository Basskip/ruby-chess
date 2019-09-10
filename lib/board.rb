class ChessBoard
    WIDTH = 8
    HEIGHT = 8
    CASTLING_ROOK_DEST = {[0,2] => [0,3], [0,6] => [0,5], [7,2] => [7,3], [7,6] => [7,5]}
    CASTLING_ROOK_ORIGIN = {[0,2] => [0,0], [0,6] => [0,7], [7,2] => [7,0], [7,6] => [7,7]}

    attr_accessor :board

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
        # REWRITE THIS TOTALLY
        @board.each do |piece|
            if piece && piece.class == King && piece.color == color
                index = @board.index(piece)
                pos = [index % HEIGHT, index / HEIGHT]
                return pos_checked?(pos, color) && piece.destinations(self, pos) == []
            end
        end
        false
    end

    def execute_move(move)
        start = move[0]
        dest = move[1]
        piece = self.pos_piece(start)
        self.place_piece(piece, dest)
        self.place_piece(nil, start)

        if piece.class == King && ((start[1] - dest[1]).abs > 1)
            rook = self.pos_piece(CASTLING_ROOK_ORIGIN[start])
            rook_dest = CASTLING_ROOK_DEST[start]
            self.place_piece(rook, rook_dest)
            rook.moved= true
        end

        # En-passant capture
        if piece.class == Pawn && (start[0] - dest[0]).abs > 0 && self.pos_free?(dest)
            passant_pos = [dest[0], start[1]]
            self.place_piece(nil, passant_pos)
        end

        self.clear_passants

        if piece.class == Pawn && (start[1] - dest[1]).abs > 1
            piece.passant_capturable= true
            piece.passant_pos= [start[0], start[1] + (dest[1] - start[1])/2]
        end

        piece.moved= true
    end

    def next_board(move)
        clone_board = @board.map(&:clone)
        result = ChessBoard.new
        result.board = clone_board
        result.execute_move(move)
        result
    end

    def check?(color)
        @board.each do |piece|
            if piece && piece.class == King && piece.color == color
                index = @board.index(piece)
                pos = [index % HEIGHT, index / HEIGHT]
                WIDTH.times do |x|
                    HEIGHT.times do |y|
                        piece = self.pos_piece([x,y])
                        if piece && piece.color != color
                            return true if piece.destinations(self,[x,y]).include?(pos)
                        end
                    end
                end
            end
        end
        false
    end

    def game_over?
        return checkmate?(:white) || checkmate?(:black) || stalemate?
    end

    def each
        @board.each do |pos|
            yield(pos)
        end
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