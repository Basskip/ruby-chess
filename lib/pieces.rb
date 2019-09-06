class Piece
    attr_reader :color
    attr_accessor :moved
    def initialize(color)
        @color = color
        @moved = false
    end
end

class DirectionalPiece < Piece
    DIRECTIONS = []
    def initialize(color)
        super(color)
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
    def initialize(color)
        super(color)
    end
end

class Rook < DirectionalPiece
    DIRECTIONS = [[0,1],[0,-1],[1,0],[-1, 0]]
    def initialize(color)
        super(color)
    end
end

class Queen < DirectionalPiece
    DIRECTIONS = [[0,1],[0,-1],[1,0],[-1, 0],[1,1],[1,-1],[-1,-1],[-1, 1]]
    def initialize(color)
        super(color)
    end
end

class Knight < Piece
    NORMAL_MOVES = [[1,2],[2,1],[2,-1],[1,-2],[-1,-2],[-2,-1],[-2,1],[-1,2]]
    def initialize(color)
        super(color)
    end

    def destinations(board, pos)
        moves = []
        NORMAL_MOVES.each do |move|
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
    def initialize(color)
        super(color)
        if color == :white
            NORMAL_MOVES = [[0,1]]
            CAPTURING_MOVES = [[-1,1],[1,1]]
            STARTING_MOVES = [[0,2]]
        elsif color == :black
            NORMAL_MOVES = [[0,-1]]
            CAPTURING_MOVES = [[-1,-1],[1,-1]]
            STARTING_MOVES = [[0,-2]]
        end
    end

    def destinations(board, pos)
        moves = []
        NORMAL_MOVES.each do |move|
            target = [pos[0] + move[0], pos[1] + move[1]]
            if board.on_board?(target) && board.pos_free?(target)
                moves << move
            end
        end
        CAPTURING_MOVES.each do |move|
            target = [pos[0] + move[0], pos[1] + move[1]]
            if board.on_board?(target) && board.pos_piece.color != self.color
                moves << move
            end
        end
        if !@moved
            STARTING_MOVES.each do |move|
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
    NORMAL_MOVES = [[0,1],[0,-1],[1,0],[-1, 0]]
    CASTLING_MOVES = [[-2,0],[2,0]]
    def initialize(color)
        super(color)
    end

    def destinations(board, pos)
        moves = []
        NORMAL_MOVES.each do |move|
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