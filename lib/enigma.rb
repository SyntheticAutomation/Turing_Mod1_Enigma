require 'date'

class Enigma

  attr_reader :key, :date, :rotations, :encrypted_message

  def initialize
    @key = ""
    @date = ""
    @rotations = 0
    @encrypted_message = ""
    @set = ("a".."z").to_a << " "
  end

  def encrypt(message_string, key = [*"00001".."99999"].sample, date = Date.today)
    @key << key
    if date == Date.today
      @date << date.strftime("%d%m%y")
    else
      @date << date
    end
    create_keys
    create_offsets
    final_shift
    {encryption: letter_encryption(message_string), key: key, date: @date}
  end

  def create_keys
    a = @key.chars[0] + @key.chars[1]
    b = @key.chars[1] + @key.chars[2]
    c = @key.chars[2] + @key.chars[3]
    d = @key.chars[3] + @key.chars[4]
    require "pry"; binding.pry if nil
    [a, b, c, d]
  end

  def create_offsets
    numeric_square = (@date.to_i ** 2).to_s
    last_four = numeric_square[-4..-1]
    a = last_four[0].to_i
    b = last_four[1].to_i
    c = last_four[2].to_i
    d = last_four[3].to_i
    [a, b, c, d]
  end

  def final_shift
    keys_as_integers = create_keys.map {|key| key.to_i}
    keys_and_offsets = [keys_as_integers, create_offsets]
    keys_and_offsets.transpose.map {|pair| pair.sum}
  end

  def rotate_once
    @rotations += 1
  end

  def letter_encryption(message_string)
    message_string.chars.map do |character|
      recognized = @set.include?(character)
      location = @set.index(character)
      rotated_shifts = final_shift.rotate(@rotations)
      if recognized && rotated_shifts.first < @set.count
        rotate_once
        position = location + rotated_shifts.first
        new_letter = @set[position] if position < @set.count
        new_letter = @set[position-@set.count] if position > @set.count
        new_letter = @set[0] if position == @set.count
        @encrypted_message << new_letter
      elsif recognized && rotated_shifts.first > @set.count
        rotate_once
        @encrypted_message << @set[location - (@set.count - (rotated_shifts.first % @set.count))]
      elsif recognized && rotated_shifts.first == @set.count
        rotate_once
        @encrypted_message << @set[location]
      else
        @encrypted_message << character
      end
    end
    @encrypted_message
  end



end