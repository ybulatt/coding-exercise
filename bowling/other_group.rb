# Use by doing something like: 
# game = BowlingGame.new
# game.new_bowl(num_pins)
# game.current_score returns the current score
# currently 0 checks for knocking down too many pins, or negative numbers, or bowling too many frames etc.
class BowlingGame
  VALID_PIN_VALUES = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10].freeze

  def initialize
    @frames = [NormalFrame.new]
    @current_score = 0
  end
  
  def run
    loop do
      num_pins = get_num_pins
      new_bowl(num_pins)
      
      display_current_score

      break if completed?
    end
    
    puts "FINAL SCORE: #{current_score}"
  end

  def new_bowl(num_pins)
    if current_frame.completed?
      if @frames.count < 9
        @frames << NormalFrame.new
      else
        @frames << LastFrame.new
      end
    end

    current_frame.new_shot(num_pins)
  end

  def current_frame
    @frames.last
  end

  def previous_frame
    return nil if frames.empty?

    frames[frames.length - 2]
  end

  def current_score
    # need to adjust for last frame just being the sum
    all_shots = @frames.map do |frame|
      frame.shots
    end.flatten
    previous_shot = 0
    second_previous_shot = 0
    score = 0
    all_shots.reverse_each do |shot|
      score += shot.num_pins
      score += previous_shot if shot.spare? || shot.strike?
      score += second_previous_shot if shot.strike?
      second_previous_shot = previous_shot
      previous_shot = shot.num_pins
    end

    score
  end
  
  def valid_input?
    if !VALID_PIN_VALUES.include?(num_pins)
      puts "INVALID. Values must be in #{VALID_PIN_VALUES}. Game over >:)"
      false
    else
      true
    end
  end
  
  def completed?
    @frames.last.last? && @frames.last.completed?
  end
  
  def get_num_pins
    loop do
      valid = true

      print 'Enter number of pins knocked down: '
      input = gets.strip

      if input.to_i.to_s != input || !VALID_PIN_VALUES.include?(input.to_i)
        puts "INVALID INPUT: Enter one of the following values #{VALID_PIN_VALUES}"
        valid = false
      elsif !current_frame.completed? && current_frame.total_pins + input.to_i > 10
        puts "INVALID INPUT: You can't knock down more than 10 pins in a set"
        valid = false
      end
      
      return input.to_i if valid
    end
  end
  
  def display_current_score
    puts "CURRENT SCORE: #{current_score}"
  end
end

class Frame
  def initialize
    @shots = []
  end

  def new_shot(num_pins)
    shot_type = if num_pins == 10 && total_shots == 0
                  'strike'
                elsif (num_pins + total_pins == 10) && total_shots == 1
                  'spare'
                else
                  'normal'
                end

    @shots << Shot.new(num_pins, shot_type)
  end

  def total_shots
    @shots.length
  end

  def total_pins
    shots.sum(&:num_pins)
  end

  def shots
    @shots
  end

	def last?
    false
  end
end

class NormalFrame < Frame
  def completed?
    total_pins == 10 || total_shots == 2
  end
end

class LastFrame < Frame
  def new_shot(num_pins)
    shots_since_last_pin_wipe = if total_shots == 0 || previous_shot.spare? || previous_shot.strike?
                                  0
                                elsif total_shots == 2 && @shots.first.strike?
                                  1
                                else
                                  2
                                end

    shot_type = if num_pins == 10 && shots_since_last_pin_wipe == 0
                  'strike'
                elsif (num_pins + total_pins == 10) && shots_since_last_pin_wipe == 1
                  'spare'
                else
                  'normal'
                end

    @shots << Shot.new(num_pins, shot_type)
  end

  def previous_shot
    return nil if @shots.empty?

    @shots[@shots.length - 2]
  end

  def completed?
    return false if total_shots < 2
    
    if shots.first.strike? || shots[1].spare?
      total_shots == 3
    else
      total_shots == 2
    end
  end

	def last?
    true
  end
end

class Shot
  # type = 'spare', 'strike', 'normal'
  def initialize(num_pins, type)
    @type = type
    @num_pins = num_pins
  end

  def num_pins
    @num_pins
  end

  def spare?
    @type == 'spare'
  end

  def strike?
    @type == 'strike'
  end
end


game = BowlingGame.new
game.run
