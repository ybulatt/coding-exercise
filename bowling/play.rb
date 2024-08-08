# frozen_string_literal: true

class BowlingGame
  def initialize(total_frames: 10)
    @total_frames = total_frames
    setup_game
  end

  def start
  end

  private

  def setup_game
    @frames = []
    (total_frames - 1).times do
      @frames << { first: nil, second: nil, score: 0 }
    end

    @frames << { first: nil, second: nil, third: nil, score: 0 }
  end
end

game = BowlingGame.new
game.start
