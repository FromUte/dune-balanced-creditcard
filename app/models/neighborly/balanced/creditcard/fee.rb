module Neighborly::Balanced::Creditcard
  class Fee
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def total
      return (@value * 1.029) + 0.30
    end
  end
end
