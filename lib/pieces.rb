class Piece
    attr_reader :color, :symbol
    attr_accessor :moved
    def initialize(color, symbol)
        @color = color
        @moved = false
        @symbol = symbol
    end
end

class DirectionalPiece < Piece
    DIRECTIONS = []
    def initialize(color, symbol)
        super(color, symbol)
    end

    def destinations(board, pos)
        moves = []
        DIRECTIONS.each do |move|
            current = pos
            target = [pos[0] + move[0], pos[1] + move[1]]
            loop do
                break unless board.on_board?(target)
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
    def initialize(color, symbol)
        super(color, symbol)
    end
end

class Rook < DirectionalPiece
    DIRECTIONS = [[0,1],[0,-1],[1,0],[-1, 0]]
    def initialize(color, symbol)
        super(color, symbol)
    end
end

class Queen < DirectionalPiece
    DIRECTIONS = [[0,1],[0,-1],[1,0],[-1, 0],[1,1],[1,-1],[-1,-1],[-1, 1]]
    def initialize(color, symbol)
        super(color, symbol)
    end
end

class Knight < Piece
    @normal_moves = [[1,2],[2,1],[2,-1],[1,-2],[-1,-2],[-2,-1],[-2,1],[-1,2]]
    def initialize(color, symbol)
        super(color, symbol)
    end

    def destinations(board, pos)
        moves = []
        @normal_moves.each do |move|
            target = [pos[0] + move[0], pos[1] + move[1]]
            if board.on_board?(target)
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
    def initialize(color, symbol)
        super(color, symbol)
        if color == :white
            @normal_moves = [[0,1]]
            @capturing_moves = [[-1,1],[1,1]]
            @starting_moves = [[0,2]]
        elsif color == :black
            @normal_moves = [[0,-1]]
            @capturing_moves = [[-1,-1],[1,-1]]
            @starting_moves = [[0,-2]]
        end
    end

    def destinations(board, pos)
        moves = []
        @normal_moves.each do |move|
            target = [pos[0] + move[0], pos[1] + move[1]]
            if board.on_board?(target) && board.pos_free?(target)
                moves << move
            end
        end
        @capturing_moves.each do |move|
            target = [pos[0] + move[0], pos[1] + move[1]]
            if board.on_board?(target) && board.pos_piece.color != self.color
                moves << move
            end
        end
        if !@moved
            @starting_moves.each do |move|
                target = [pos[0] + move[0], pos[1] + move[1]]
                #This will work for now
                en_route = [pos[0], pos[1] + move[1]/2]
                if board.on_board?(target) && board.pos_free?(target) && board.pos_free?(en_route)
                    moves << move
                end
            end
        end
    end
end

class King < Piece
    @normal_moves = [[0,1],[0,-1],[1,0],[-1, 0]]
    CASTLING_MOVES = [[-2,0],[2,0]]
    def initialize(color, symbol)
        super(color, symbol)
    end

    def destinations(board, pos)
        moves = []
        @normal_moves.each do |move|
            target = [pos[0] + move[0], pos[1] + move[1]]
            if board.on_board?(target)
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
        if !@moved
            # Left rook
            rook_pos = [pos[0] - 4, pos[1]]
            piece = board.pos_piece(rook_pos)
            if piece.class == Rook && piece.moved == false
                moves << [pos[0] - 2, pos[1]]
            end
            # Right rook
            rook_pos = [pos[0] + 3, pos[1]]
            piece = board.pos_piece(rook_pos)
            if piece.class == Rook && piece.moved == false
                moves << [pos[0] + 2, pos[1]]
            end
        end
        moves
    end
end