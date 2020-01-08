# frozen_string_literal: true

# encode points to string
class IntPointsDecoder
  DICTIONARY_VALUES = \
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef'\
    'ghijklmnopqrstuvwxyz0123456789_-'.chars.map.with_index.to_h

  def encode(points)
    encoded_values = []

    last_point = [0, 0]
    points.each do |point|
      index = extract_index_from_points(point, last_point)
      append_index_to_encoded_values(encoded_values, index)
      last_point = point
    end

    encoded_values.join('')
  end

  def decode(encoded_string)
    encoded_chars = encoded_string.chars

    return { points: [], success: true } if encoded_chars.empty?

    pairs = read_all_encoded_pairs(encoded_chars)
    return { points: [], success: false } if pairs.nil?

    { points: transform_to_coordinates(pairs), success: true }
  end

  def transform_to_coordinates(pairs)
    coordinate_sum = [0, 0]
    coordinates = []

    pairs.map do |pair|
      delta = to_coordinate(pair)

      coordinate_sum = coordinate_sum.zip(delta).map { |a| a.reduce(:+) }
      coordinates.push(coordinate_sum)
    end

    coordinates
  end

  def read_all_encoded_pairs(encoded_chars)
    pairs = []

    chars = encoded_chars[0..-1]
    loop do
      success, pair_value, chars = to_pair_value(chars)
      return nil unless success

      pairs.push(pair_value)
      break if chars.empty?
    end
    pairs
  end

  private

  def to_pair_value(chars)
    bit_index = 0
    value = 0

    loop do
      # return use_non_32bit_fallback(value, chars) if bit_index >= 30

      success, decoded_char = decode_encoded_char(chars)
      return [false, nil, nil] unless success

      value = append_with_32bit_op(value, decoded_char, bit_index)
      bit_index += 5

      return [true, value, chars] if final_char?(decoded_char)
    end
  end

  # JUST FOR JS ONLY
  # def use_non_32bit_fallback(value, chars)
  #   factor = 1 << 30

  #   loop do
  #     success, decoded_char = decode_encoded_char(chars)
  #     return [false, nil, nil] unless success

  #     value = append_with_non_32bit_op(value, decoded_char, factor)
  #     factor *= 32

  #     return [true, value, chars] if final_char?(decoded_char)
  #   end
  # end

  def to_lower_bits(decoded_char)
    decoded_char & 31
  end

  def final_char?(decoded_char)
    decoded_char < 32
  end

  def decode_encoded_char(remaining_letters)
    return [false, nil] if remaining_letters.empty?

    encoded_char = remaining_letters.shift
    decoded_char = DICTIONARY_VALUES[encoded_char]

    [!decoded_char.nil?, decoded_char]
  end

  def append_with_non_32bit_op(value, decoded_char, factor)
    lower_bits = to_lower_bits(decoded_char)

    value + (lower_bits * factor)
  end

  def append_with_32bit_op(value, decoded_char, bit_index)
    lower_bits = to_lower_bits(decoded_char)
    value | (lower_bits << bit_index)
  end

  def to_coordinate(pair_string)
    # The resulting number encodes an x, y pair in the following way:
    # https://math.stackexchange.com/questions/1417579/largest-triangular-number-less-than-a-given-natural-number

    triangle_lookup = calculate_triangular_number(pair_string)

    largest_complete_triangle = triangle_lookup.floor
    sum_of_lat_and_long = largest_complete_triangle - 1

    elements_in_triangles = sum_of_lat_and_long * largest_complete_triangle
    elements_in_triangles /= 2

    nx = pair_string - elements_in_triangles
    ny = sum_of_lat_and_long - nx

    [nx, ny].map { |n| undo_sign_encoding n }
  end

  def calculate_triangular_number(encoded_pair)
    (1 + Math.sqrt(8 * encoded_pair + 1)) / 2
  end

  def undo_sign_encoding(num)
    (num >> 1) ^ -(num & 1)
  end
end
