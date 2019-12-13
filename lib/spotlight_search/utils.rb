

module SpotlightSearch::Utils
  class << self
    def serialize_csv_columns(*columns, **hashes)
      # Turns an arbitrary list of args and kwargs into a list of params to be used in a form
      # For example, turns serialize_csv_columns(:a, :b, c: [:d, e: :h], f: :g)
      # into [:a, :b, "c/d", "c/e/h", "f/g"]
      columns + hashes.map do |key, value|
        serialize_csv_columns(*value).map do |column|
          "#{key}/#{column}"
        end
      end.reduce([], :+)
    end

    def deserialize_csv_columns(list)
      # Does the opposite operation of the above
      list.reduce(columns: [], associations: {}) do |acc, item|
        tokens = item.to_s.split('/')
        bury(acc, tokens.shift, tokens)
      end
    end

    def bury(hash, key, tokens) # recursive
      if tokens.size == 0
        # base case
        hash[:columns] << key
      else
        # recursive case
        hash[:associations][key] ||= { columns: [], associations: {} }
        hash[:associations][key] = bury(hash[:associations][key], tokens.shift, tokens)
      end
      hash
    end
  end
end
