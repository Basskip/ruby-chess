class Piece
    attr_reader :color, :symbol, :letter
    attr_accessor :moved
    def initialize(color, symbol, letter)
        @color = color
        @moved = false
        @symbol = symbol
        @letter = letter
    end

    def capture_spaces(board, pos)
        self.destinations(board,pos)
    end
end

class DirectionalPiece < Piece
    DIRECTIONS = []
    def initialize(color, symbol, letter)
        super(color, symbol, letter)
    end

    def destinations(board, pos)
        moves = []
        (self.class::DIRECTIONS).each do |move|
            current = pos
            target = [pos[0] + move[0], pos[1] + move[1]]
            loop do
                break unless ChessBoard.on_board?(target)
                # Blocked by something
                if !board.pos_free?(target)
                    blocker = board.pos_piece(target)
                    # Blocker is an enemy piece
                    moves << target if blocker.color != self.color
                    break
                else
                    moves << target
                    current = target
                    target = [current[0] + move[0], current[1] + move[1]]
                end
            end
        end
        moves
    end
end

class Bishop < DirectionalPiece
    DIRECTIONS = [[1,1],[1,-1],[-1,-1],[-1, 1]]
    def initialize(color)
        super(color, "\u{265D}", "B") if color == :black
        super(color, "\u{2657}", "B") if color == :white
    end
end

class Rook < DirectionalPiece
    DIRECTIONS = [[0,1],[0,-1],[1,0],[-1, 0]]
    def initialize(color)
        super(color, "\u{265C}", "R") if color == :black
        super(color, "\u{2656}", "R") if color == :white
    end
end

class Queen < DirectionalPiece
    DIRECTIONS = [[0,1],[0,-1],[1,0],[-1, 0],[1,1],[1,-1],[-1,-1],[-1, 1]]
    def initialize(color)
        super(color, "\u{265B}", "Q") if color == :black
        super(color, "\u{2655}", "Q") if color == :white
    end
end

class Knight < Piece
    NORMAL_MOVES = [[1,2],[2,1],[2,-1],[1,-2],[-1,-2],[-2,-1],[-2,1],[-1,2]]
    def initialize(color)
        super(color, "\u{265E}", "N") if color == :black
        super(color, "\u{2658}", "N") if color == :white
    end

    def destinations(board, pos)
        moves = []
        NORMAL_MOVES.each do |move|
            target = [pos[0] + move[0], pos[1] + move[1]]
            if ChessBoard.on_board?(target)
                if board.pos_free?(target)
                    moves << target
                else
                    blocker = board.pos_piece(target)
                    if blocker.color != self.color
                        moves << target
                    end
                end
            end
        end
        moves
    end
end

class Pawn < Piece
    attr_accessor :passant_capturable, :passant_pos
    def initialize(color, symbol)
        super(color, symbol, "P")
        @passant_capturable = false
        @passant_pos = nil
        if color == :white
            @normal_moves = [[0,1]]
            @capturing_moves = [[-1,1],[1,1]]
            @starting_moves = [[0,2]]
        elsif color == :black
            @normal_moves = [[0,-1]]
            @capturing_moves = [[-1,-1],[1,-1]]
            @starting_moves = [[0,-2]]
        end
        @passant_directions = [[1,0],[-1,0]]
    end

    def capture_spaces(board, pos)
        moves = []
        @capturing_moves.each do |move|
            target = [pos[0] + move[0], pos[1] + move[1]]
            if ChessBoard.on_board?(target)
                moves << move
            end
        end
        moves
    end

    def destinations(board, pos)
        moves = []
        @normal_moves.each do |move|
            target = [pos[0] + move[0], pos[1] + move[1]]
            if ChessBoard.on_board?(target) && board.pos_free?(target)
                moves << target
            end
        end
        @capturing_moves.each do |move|
            target = [pos[0] + move[0], pos[1] + move[1]]
            if ChessBoard.on_board?(target) && !board.pos_free?(target) && board.pos_piece(target).color != self.color
                moves << target
            end
        end
        if !@moved
            @starting_moves.each do |move|
                target = [pos[0] + move[0], pos[1] + move[1]]
                #This will work for now
                en_route = [pos[0], pos[1] + move[1]/2]
                if ChessBoard.on_board?(target) && board.pos_free?(target) && board.pos_free?(en_route)
                    moves << target
                end
            end
        end
        @passant_directions.each do |direction|
            candidate_pos = [pos[0] + direction[0], pos[1] + direction[1]]
            piece = board.pos_piece(candidate_pos)
            if piece && piece.class == Pawn && piece.passant_capturable
                moves << piece.passant_pos
            end
        end
        moves
    end
end

class King < Piece
    NORMAL_MOVES = [[0,1],[0,-1],[1,0],[-1, 0]]
    CASTLING_MOVES = [[-2,0],[2,0]]
    def initialize(color)
        super(color, "\u{265A}", "K") if color == :black
        super(color, "\u{2654}", "K") if color == :white
    end

    def capture_spaces(board,pos)
        moves = []
        NORMAL_MOVES.each do |move|
            target = [pos[0] + move[0], pos[1] + move[1]]
            if ChessBoard.on_board?(target)
                    moves << target 
            end
        end
        moves
    end

    def destinations(board, pos)
        moves = []
        NORMAL_MOVES.each do |move|
            target = [pos[0] + move[0], pos[1] + move[1]]
            if ChessBoard.on_board?(target)
                if board.pos_free?(target)
                    moves << target unless board.pos_checked?(target, self.color)
                else
                    blocker = board.pos_piece(target)
                    if blocker.color != self.color
                        moves << target
                    end
                end
            end
        end
        if !@moved
            # Left rook
            rook_pos = [pos[0] - 4, pos[1]]
            piece = board.pos_piece(rook_pos)
            if piece.class == Rook && piece.moved == false && piece.color == self.color
                moves << [pos[0] - 2, pos[1]]
            end
            # Right rook
            rook_pos = [pos[0] + 3, pos[1]]
            piece = board.pos_piece(rook_pos)
            if piece.class == Rook && piece.moved == false && piece.color == self.color
                moves << [pos[0] + 2, pos[1]]
            end
        end
        moves
    end
end