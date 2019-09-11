require './lib/board'
require './lib/pieces'

describe ChessBoard do
    before(:each) do
        @board = ChessBoard.new
    end
    describe "#initialize" do
        it "creates a new 8*8 array" do
            expect(@board.board.size).to eql(64)
        end
    end
    describe "#place_piece" do
        it "places a piece on the board" do
            piece = Rook.new(:white)
            @board.place_piece(piece,[0,0])
            expect(@board.board[0]).to equal(piece)
        end
        it "overrides a previously placed piece" do
            piece1 = Rook.new(:white)
            piece2 = Queen.new(:black)
            @board.place_piece(piece1,[0,0])
            @board.place_piece(piece2,[0,0])
            expect(@board.board[0]).to equal(piece2)
        end
    end
    describe "#check?" do
        it "returns false for an empty board" do
            expect(@board.check?(:white)).to eql(false)
        end
        it "returns false for a board with only kings" do
            @board.place_piece(King.new(:white),[0,0])
            @board.place_piece(King.new(:black),[7,7])
            expect(@board.check?(:white)).to eql(false)
        end
        it "returns true when the king is under attack" do
            @board.place_piece(King.new(:white),[0,0])
            @board.place_piece(Queen.new(:black),[0,4])
            expect(@board.check?(:white)).to eql(true)
        end
        it "returns false if the attack on the king is blocked by another piece" do
            @board.place_piece(King.new(:white),[0,0])
            @board.place_piece(Rook.new(:white),[0,2])
            @board.place_piece(Queen.new(:black),[0,4])
            expect(@board.check?(:white)).to eql(false)
        end
    end
    describe "#checkmate?" do 
        it "returns false for an empty board" do
            expect(@board.checkmate?(:white)).to eql(false)
        end
        it "returns true for a simple checkmate" do
            @board.place_piece(King.new(:white),[0,0])
            @board.place_piece(Pawn.new(:white),[0,1])
            @board.place_piece(Bishop.new(:white),[1,0])
            @board.place_piece(Queen.new(:black),[3,3])
            expect(@board.checkmate?(:white)).to eql(true)
        end
        it "returns false when the checkmate could be broken by capturing" do
            @board.place_piece(King.new(:white),[0,0])
            @board.place_piece(Pawn.new(:white),[0,1])
            @board.place_piece(Bishop.new(:white),[1,0])
            @board.place_piece(Queen.new(:black),[3,3])
            @board.place_piece(Rook.new(:white),[3,5])
            expect(@board.checkmate?(:white)).to eql(false)
        end
    end
    describe "#no_legal_moves?" do
        it "returns true for an empty board" do
            expect(@board.no_legal_moves?(:white)).to eql(true)
        end
        it "returns false for a board with moves available" do
            @board.place_piece(King.new(:white),[3,3])
            expect(@board.no_legal_moves?(:white)).to eql(false)
        end
        it "returns false for a single pawn with nowhere left to go" do
            @board.place_piece(Pawn.new(:black),[0,0])
            expect(@board.no_legal_moves?(:black)).to eql(true)
        end
        it "returns true for a stalemated king" do
            @board.place_piece(King.new(:black),[7,7])
            @board.place_piece(King.new(:white),[5,6])
            @board.place_piece(Queen.new(:white),[6,5])
            expect(@board.no_legal_moves?(:black)).to eql(true)
        end
    end
end