# frozen_string_literal: true

class BowlingGame
  attr_reader :total_frames, :bowls_per_frame, :total_pins_per_frame, :frames, :scores, :error_message

  STRIKE_CHARACTER = 'x'
  SPARE_CHARACTER = '/'

  def initialize(total_frames: 10, bowls_per_frame: 2, total_pins_per_frame: 10)
    @total_frames = total_frames
    @bowls_per_frame = bowls_per_frame
    @total_pins_per_frame = total_pins_per_frame
    @frames = []
    @scores = []
  end

  def start
    # TODO: puts warning and break if game settings invalid
    get_frames
    get_scores
    # display_scores
  end

  private

  def get_frames
    1.upto(total_frames) do |frame_number|
      frame = get_frame(frame_number)
      frames << frame
    end

    give_extra_bowls if eligible_for_extra_bowls?
  end

  def get_frame(frame_number = nil)
    puts "Frame: #{frame_number}" unless frame_number.nil?

    frame = []

    bowls_per_frame.times do
      loop do
        pins_knocked_down = get_input_for_pins_knocked_down

        pins_knocked_down = parse_strike_or_spare(frame, pins_knocked_down)

        if valid_input?(frame, pins_knocked_down)
          frame << pins_knocked_down
          break
        else
          puts error_message
        end
      end

      break if strike_frame?(frame) || spare_frame?(frame)
    end

    frame
  end

  def eligible_for_extra_bowls?
    extra_bowls >= 1
  end

  def extra_bowls
    last_frame = frames.last

    if strike_frame?(last_frame)
      2
    elsif spare_frame?(last_frame)
      1
    else
      0
    end
  end

  def give_extra_bowls
    puts "Nice one. You're getting #{extra_bowls} extra deliver#{extra_bowls == 1 ? 'y' : 'ies'}."

    last_frame = frames.last

    extra_bowls.times do
      loop do
        pins_knocked_down = get_input_for_pins_knocked_down
        dummy_frame = []
        # Only a strike can be parsed. Spare is not possible in this scenario.
        pins_knocked_down = parse_strike_or_spare(dummy_frame, pins_knocked_down)

        if valid_input?(dummy_frame, pins_knocked_down)
          last_frame << pins_knocked_down
          break
        else
          puts error_message
        end
      end
    end
  end

  def get_input_for_pins_knocked_down
    print 'Pins knocked down: '
    input = gets
    input.strip.downcase
  end

  def parse_strike_or_spare(frame, pins_knocked_down)
    return pins_knocked_down if strike?(pins_knocked_down) || spare?(pins_knocked_down)

    if frame.empty? && pins_knocked_down.to_i == total_pins_per_frame
      STRIKE_CHARACTER
    elsif frame.map(&:to_i).sum + pins_knocked_down.to_i == total_pins_per_frame
      SPARE_CHARACTER
    else
      pins_knocked_down
    end
  end

  # Takes a string representing a bowl (eg '1', '7', 'x', '/', etc).
  # Returns whether the bowl was a strike.
  def strike?(pins_knocked_down)
    pins_knocked_down == STRIKE_CHARACTER
  end

  # Takes a string representing a bowl (eg '1', '7', 'x', '/', etc).
  # Returns whether the bowl was a spare.
  def spare?(pins_knocked_down)
    pins_knocked_down == SPARE_CHARACTER
  end

  # Takes a frame
  # Returns whether the frame was a strike.
  def strike_frame?(frame)
    strike?(frame.first)
  end

  # Takes a frame
  # Returns whether the frame was a spare.
  def spare_frame?(frame)
    spare?(frame.last)
  end

  def valid_input?(frame, pins_knocked_down)
    @error_message = 
      if !valid_characters.include?(pins_knocked_down)
        "Invalid input. Enter one of the following: #{valid_characters}"
      elsif invalid_strike?(frame, pins_knocked_down)
        'Liar. A strike is not possible after the first bowl in a delivery.'
      elsif invalid_spare?(frame, pins_knocked_down)
        'Liar. A spare is not possible in the first bowl in a delivery.'
      elsif invalid_number_of_pins?(frame, pins_knocked_down)
        "Liar. You can't knock down more than #{total_pins_per_frame} pins in a delivery when there are only #{total_pins_per_frame} pins per delivery."
      else
        nil
      end

    error_message.nil?
  end

  def valid_characters
    @valid_characters ||= ([STRIKE_CHARACTER, SPARE_CHARACTER] + (0..total_pins_per_frame).to_a.map(&:to_s)).freeze
  end

  def invalid_strike?(frame, pins_knocked_down)
    !frame.empty? && strike?(pins_knocked_down)
  end

  def invalid_spare?(frame, pins_knocked_down)
    frame.empty? && spare?(pins_knocked_down)
  end

  def invalid_number_of_pins?(frame, pins_knocked_down)
    frame.map(&:to_i).sum + pins_knocked_down.to_i > total_pins_per_frame
  end

  def get_scores
    frames.each_with_index do |frame, index|
      total_score_this_frame = frame_total(frame)

      unless index == total_frames - 1
        if strike_frame?(frame)
          next_2_shots = next_n_shots(index, 2)
          total_score_this_frame += frame_total(next_2_shots)
        elsif spare_frame?(frame)
          next_shot = next_n_shots(index, 1)
          total_score_this_frame += frame_total(next_shot)
        end
      end

      total_score_this_frame += scores.last unless scores.empty?
      scores << total_score_this_frame
    end
  end

  # Return the next n shots after frame number (index + 1)
  def next_n_shots(index, n)
    next_n_frames = frames[index + 1, index + 1 + n]
    next_n_shots = next_n_frames.flatten[0, n]
  end

  def frame_total(frame)
    total = 0

    if spare_frame?(frame) && strike_frame?(frame)
      total += total_pins_per_frame * (frame.count(SPARE_CHARACTER) + frame.count(STRIKE_CHARACTER))
    elsif spare_frame?(frame)
      total += total_pins_per_frame
    else
      total += frame.count(STRIKE_CHARACTER) * total_pins_per_frame + frame.map(&:to_i).sum
    end
  end
end

game = BowlingGame.new
game.start
game.frames.each_with_index do |frame, frame_number|
  puts "FRAME #{frame_number}: #{frame}, SCORE: #{game.scores[frame_number]}"
end
