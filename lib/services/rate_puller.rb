module Coingate

  class RatePuller
    def self.pull_all
      [ BitstampPuller.new ].map( &:pull )
    end
  end

end
