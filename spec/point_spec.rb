require 'spec_helper'

describe ECDSA::Point do
  let(:group) do
    ECDSA::Group::Secp256k1
  end

  describe 'multiply_by_scalar' do
    it 'does not give infinity when we multiply the generator of secp256k1 by a number less than the order' do
      # this test was added to fix a particular bug
      k = 2
      expect(k).to be < group.order
      point = group.generator.multiply_by_scalar(k)
      expect(point).to_not be_infinity
    end
    
    it 'complains if the argument is not an integer' do
      expect { group.generator.multiply_by_scalar(1.1) }.to raise_error ArgumentError, 'Scalar is not an integer.'
    end
    
    it 'complains if the argument is negative' do
      expect { group.generator.multiply_by_scalar(-3) }.to raise_error ArgumentError, 'Scalar is negative.'    
    end
  end
  
  describe '#coords' do
    it 'returns [nil, nil] for infinity' do
      expect(group.infinity_point.coords).to eq [nil, nil]
    end
    
    it 'returns x and y' do
      expect(group.generator.coords).to eq [
          0x79BE667E_F9DCBBAC_55A06295_CE870B07_029BFCDB_2DCE28D9_59F2815B_16F81798,
          0x483ADA77_26A3C465_5DA4FBFC_0E1108A8_FD17B448_A6855419_9C47D08F_FB10D4B8]
    end
  end
  
  describe '#double' do
    it 'returns infinity for infinity' do
      expect(group.infinity_point.double).to eq group.infinity_point
    end
    
    it 'can double the generator' do
      expect(group.generator.double).to_not be_infinity
    end
  end

  describe 'add_to_point' do
    context 'when adding point + infinity' do
      it 'returns the point' do
        expect(group.generator.add_to_point(group.infinity_point)).to eq group.generator
      end
    end

    context 'when adding infinity + point' do
      it 'returns the point' do
        expect(group.infinity_point.add_to_point(group.generator)).to eq group.generator
      end
    end
  end

  describe 'negate' do
    it 'returns infinity for infinity' do
      expect(group.infinity_point.negate).to eq group.infinity_point
    end

    it 'returns a point with same x coordinate but negated y coordinate' do
      n = group.generator.negate
      expect(n.x).to eq group.generator.x
      expect(n.y).to eq group.field.mod(-group.generator.y)
    end
  end

  describe 'double' do
    it 'can double the generator of secp256k1' do
      point = group.generator.double
      expect(point).to_not be_infinity
    end
  end

  describe '#inspect' do
    it 'shows the coordinates if the point has them' do
      expect(group.generator.inspect).to eq '#<ECDSA::Point: secp256k1, ' \
        '0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, ' \
        '0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8>'
    end

    it 'shows infinity if the point is infinity' do
      expect(group.infinity_point.inspect).to eq '#<ECDSA::Point: secp256k1, infinity>'
    end
  end
end
