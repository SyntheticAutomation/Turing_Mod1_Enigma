require 'date'
require './lib/encrypter'

class Enigma

  attr_reader :key, :date, :decrypted_message

  def initialize
    @key = ""
    @date = ""
    @decrypted_message = ""
  end

  def encrypt(message, key = [*"00001".."99999"].sample, date = Date.today)
    @key << key
    (date == Date.today) ? (@date << date.strftime("%d%m%y")) : (@date << date)
    create_keys
    create_offsets
    final_shift
    encrypter = Encrypter.new
    new_text = encrypter.letter_encryption(message.downcase.chomp)
    {encryption: new_text, key: key, date: @date}
  end

  def create_keys
    a = @key.chars[0] + @key.chars[1]
    b = @key.chars[1] + @key.chars[2]
    c = @key.chars[2] + @key.chars[3]
    d = @key.chars[3] + @key.chars[4]
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

  def decrypt(message, key, date = Date.today)
    @key << key
    (date == Date.today) ? (@date << date.strftime("%d%m%y")) : (@date << date)
    create_keys
    create_offsets
    final_shift
    {decryption: letter_decryption(message.downcase.chomp), key: key, date: @date}
  end

  def letter_decryption(message)
    set = ("a".."z").to_a << " "
    rotations = 0
    message.class == String ? characters_array = message.chars : characters_array = message[:encryption].chars
    characters_array.each do |character|
      recognized = set.include?(character)
      index = set.index(character)
      rotated_shifts = final_shift.rotate(rotations)
      if recognized
      @decrypted_message << (set.rotate(-1 * rotated_shifts[0])[index])
        rotations += 1
      else
        @decrypted_message << character
      end
    end
      @decrypted_message
  end

end
