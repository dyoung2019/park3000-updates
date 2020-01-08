# frozen_string_literal: true

require_relative '../int_points'

describe IntPoints do
  let(:encoder) { described_class.new }
  let(:encoding_string) { 'vx1vilihnM6hR7mEl2Q' }
  let(:sample_points) do
    [
      [3_589_431, -11_072_522],
      [3_589_393, -11_072_578],
      [3_589_374, -11_072_606],
      [3_589_337, -11_072_662]
    ]
  end

  it 'returns allowed values of length of 64' do
    expect(described_class::ALLOWED_VALUES.length).to eq 64
  end

  context 'with encoding' do
    it 'return an empty string' do
      expect(encoder.encode([])).to eq ''
    end

    it 'returns a encoded string' do
      expect(encoder.encode(sample_points)).to eq encoding_string
    end
  end

  context 'with decoding' do
    it 'returns passing empty string' do
      expect(encoder.decode('')).to eq({ points: [], success: true })
    end

    it 'returns actual values' do 
      expect(encoder.decode(encoding_string)).to eq({ points: sample_points, success: true })
    end
  end
end
