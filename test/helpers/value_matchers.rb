module Helpers
  module ValueMatchers
    ### Matchers
    def matches_value?(v1, v2, **options)
      if v1 == :any
        # any value is acceptable
      elsif v1 == :not_nil
        return false if v2 == nil
      elsif v1.kind_of?(Hash)
        return false unless matches_hash?(v1, v2, **options)
      elsif v1.kind_of?(Array)
        return false unless matches_array?(v1, v2, **options)
      else
        return false unless v2 == v1
      end
      true
    end

    def matches_array?(array1, array2, **options)
      return false unless array1.kind_of?(Array) && array2.kind_of?(Array)
      if options[:exact]
        return false unless array1.size == array2.size
      end

      # order of items shouldn't matter:
      #    ['a', 'b', 'c'], ['b', 'c', 'a'] -> true
      #
      # matched items should only be used once:
      #    ['a', 'b', 'c'], ['a', 'a', 'a'] -> false
      #    ['a', 'a', 'a'], ['a', 'b', 'c'] -> false
      matched = {}
      (0..(array1.size - 1)).each do |i|
        (0..(array2.size - 1)).each do |j|
          if !matched.has_value?(j.to_s) && matches_value?(array1[i], array2[j], **options)
            matched[i.to_s] = j.to_s
            break
          end
        end
        return false unless matched.has_key?(i.to_s)
      end
      true
    end

    # options => {exact: true} # hashes must match exactly (i.e. have same number of key-value pairs that are all equal)
    def matches_hash?(hash1, hash2, **options)
      return false unless hash1.kind_of?(Hash) && hash2.kind_of?(Hash)
      if options[:exact]
        return false unless hash1.size == hash2.size
      end

      hash1 = hash1.deep_symbolize_keys
      hash2 = hash2.deep_symbolize_keys

      hash1.each do |k1, v1|
        return false unless hash2.has_key?(k1) && matches_value?(v1, hash2[k1], **options)
      end
      true
    end
  end
end