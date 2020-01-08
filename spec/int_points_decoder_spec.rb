# frozen_string_literal: true

require_relative '../int_points_decoder'

describe IntPointsDecoder do
  let(:enc) { described_class.new }
  let(:enc_string) { 'vx1vilihnM6hR7mEl2Q' }
  let(:sample_points) do
    [
      [3_589_431, -11_072_522],
      [3_589_393, -11_072_578],
      [3_589_374, -11_072_606],
      [3_589_337, -11_072_662]
    ]
  end

  context 'with decoding' do
    it 'returns passing empty array on empty string' do
      expect(enc.decode('')).to eq(points: [], success: true)
    end

    it 'returns actual values' do
      expect(enc.decode(enc_string)).to eq(points: sample_points, success: true)
    end

    it 'returns empty array on garbage' do
      expect(enc.decode('$%^%^%^')).to eq(points: [], success: false)
    end
  end
end
