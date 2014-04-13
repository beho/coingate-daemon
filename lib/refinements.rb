module Coingate
  module Refinements

    refine Hash do
      def with_symbol_keys
        inject({}) do |memo, (k, v)|
          memo[k.to_sym] = v.kind_of?( Hash ) ? v.with_symbol_keys : v
          memo
        end
      end
    end

  end
end
