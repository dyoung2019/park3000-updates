# frozen_string_literal: true
require 'pry'


# encode points to string
class IntPoints
  ALLOWED_VALUES = \
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef'\
    'ghijklmnopqrstuvwxyz0123456789_-'
  DICTIONARY_VALUES = ALLOWED_VALUES.chars.map.with_index.to_h

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
    list = []
    index = 0
    xsum = 0
    ysum = 0
  
    string_length = encoded_string.length

    return { points: [], success: true } if (string_length <= 0)

    # While we have more data
    loop do
      break unless index < string_length

      n = 0
      k = 0
      factor = 1 << 30

      loop do 

        if (index >= string_length)
          binding.pry
          return { points: [], success: false, dropped: 2  } 
        end


        chunk = encoded_string[index]
        index += 1
        b = DICTIONARY_VALUES[chunk]

        return { points:[], success: false, dropped: 3 } if (b == nil)

        lower_bits = b & 31
      
        can_use_32_bitwise_ops = k < 30
        if can_use_32_bitwise_ops 
          n |= lower_bits << k
        else
          n += lower_bits * factor
          factor *= 32
        end

        k += 5

        break if b < 32

      end

      # The resulting number encodes an x, y pair in the following way:  
  
      # https://math.stackexchange.com/questions/1417579/largest-triangular-number-less-than-a-given-natural-number

      triangle_lookup = (1 + Math.sqrt(8 * n + 1)) / 2
      largest_complete_triangle = triangle_lookup.floor
      sum_of_lat_and_long = largest_complete_triangle - 1
      elements_in_triangles = (sum_of_lat_and_long * largest_complete_triangle) / 2
      x_delta = n - elements_in_triangles

      # get the X and Y from what's left over  
      nx = x_delta
      ny = sum_of_lat_and_long - x_delta

      # undo the sign encoding  
      nx = (nx >> 1) ^ -(nx & 1)  
      ny = (ny >> 1) ^ -(ny & 1)  

      xsum += nx
      ysum += ny

      coord = [xsum, ysum]

      list.push(coord)
    end

    {
      points: list,
      success: true
    }
  end

  private

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

  def push_encoded_values(encoded_values, rem)
    encoded_values.push(ALLOWED_VALUES[rem])
  end

  def extract_index_from_points(current, previous)
    mask = encode_point(current, previous)
    calculate_index_value_of_mask(mask)
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
end
