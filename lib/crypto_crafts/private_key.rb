require 'securerandom'

class PrivateKey
  attr_reader :value, :order

  def self.generate
    value = 1 + SecureRandom.random_number(EC_n - 1)
    new value, EC_n
  end

  def initialize(value, order = nil)
    @value = value
    @order = order
  end
end
