# frozen_string_literal: true

class BowlingGame
  def initialize(total_frames: 10)
    @total_frames = total_frames
    @frames = []
    @scores_per_frame = []
  end

  def start
    total_frames.times do |index|
      puts "Frame: #{index + 1}"

      frame = []

      2.times do
        puts "Pins knocked down:"
        pins = gets
        frame << pins

        break if pins&.downcase == 'x'?
      end

      extra_bowls = 0

      if index == total_frames - 1
        if frame.first&.downcase == 'x'
          extra_bowls = 2
        elsif frame.second == '/'
          extra_bowls = 1
        end
      end

      extra_bowls.times do
        puts "Pins knocked down:"
        pins = gets
        frame << pins
      end

      @frames << frame
    end

    @frames.each_with_index do |frame, index|
      puts "Frame: #{index + 1}"

      total_score_this_frame = 0

      if frame.include?('x') || frame.include?('X')
        total_score_this_frame += 10
        
        break if index == @total_frames + 1

        next_frame = @frames[index + 1]

        if next_frame.include?('x') || next_frame.include?('X') || next_frame.include?('/')
          total_score_this_frame += 10
        else
          total_score_this_frame += next_frame.map(&:to_i).sum
        end
      elsif frame.include?('/')
        total_score_this_frame += 10

        if next_frame.include?('x') || next_frame.include?('X') || next_frame.include?('/')
          total_score_this_frame += 10
        else
          total_score_this_frame += next_frame.map(&:to_i).first
        end
      else
        total_score_this_frame += frame.map(&:to_i).sum
      end

      total_score_this_frame += @scores_per_frame.sum

      @scores_per_frame << total_score_this_frame

      puts "Score: #{total_score_this_frame}"
    end
  end
end

game = BowlingGame.new
game.start
