# frozen_string_literal: true

require_relative '../int_points_encoder'

describe IntPointsEncoder do
  let(:enc) { described_class.new }

  context 'with valid input' do
    let(:enc_string) { 'vx1vilihnM6hR7mEl2Q' }
    let(:sample_points) do
      [
        [3_589_431, -11_072_522],
        [3_589_393, -11_072_578],
        [3_589_374, -11_072_606],
        [3_589_337, -11_072_662]
      ]
    end

    context 'with encoding' do
      it 'return an empty string' do
        expect(enc.encode([])).to eq ''
      end

      it 'returns a encoded string' do
        expect(enc.encode(sample_points)).to eq enc_string
      end
    end
  end

  it 'returns nil with invalid coodinate format' do
    expect(enc.encode([[3_589_431]])).to be nil
  end
end
