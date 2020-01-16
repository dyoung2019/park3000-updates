# frozen_string_literal: true

# encode array of points to string
class IntPointsEncoder
  ALLOWED_VALUES = \
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef'\
    'ghijklmnopqrstuvwxyz0123456789_-'
  DICTIONARY_VALUES = ALLOWED_VALUES.chars.map.with_index.to_h

  def encode(points)
    return nil unless valid_points?(points)

    encoded_values = []

    last_point = [0, 0]
    points.each do |point|
      index = extract_index_from_points(point, last_point)
      append_index_to_encoded_values(encoded_values, index)
      last_point = point
    end

    encoded_values.join('')
  end

  private

  def valid_points?(points)
    return false if points.nil?

    points.each do |pt|
      return false if pt.length != 2
    end

    true
  end

  def extract_index_from_points(current, previous)
    mask = encode_point(current, previous)
    calculate_index_value_of_mask(mask)
  end

  def append_index_to_encoded_values(encoded_values, index)
    loop do
      break if index <= 0

      # step 7
      rem = index & 31
      index = (index - rem) / 32

      # step 8
      rem += 32 if index.positive?

      # step 9
      push_encoded_values(encoded_values, rem)
    end
  end

  def encode_point(current, previous)
    current.zip(previous).map { |p| extract_mask p.reduce(:-) }
  end

  def extract_mask(delta)
    (delta << 1) ^ (delta >> 31)
  end

  def calculate_index_value_of_mask(mask)
    sum = mask.reduce(:+)
    # index = ((mask_dy + mask_dx) * (mask_dy + mask_dx + 1) / 2) + mask_dy
    ((sum * (sum + 1)) / 2) + mask[0]
  end

  def push_encoded_values(encoded_values, rem)
    encoded_values.push(ALLOWED_VALUES[rem])
  end
end
