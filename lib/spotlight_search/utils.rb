

module SpotlightSearch::Utils
  class << self
    def serialize_csv_columns(*columns, **hashes)
      # Turns an arbitrary list of args and kwargs into a list of params to be used in a form
      # For example, turns SpotlightSearch::Utils.serialize_csv_columns(:a, :b, c: [:d, e: :h], f: :g)
      # into [:a, :b, "c/d", "c/e/h", "f/g"]
      columns + hashes.map do |key, value|
        serialize_csv_columns(*value).map do |column|
          "#{key}/#{column}"
        end
      end.reduce([], :+)
    end

    def deserialize_csv_columns(list, method)
      # Does the opposite operation of the above
      list.reduce(recursive_hash) do |acc, item|
        tokens = item.to_s.split('/')
        send(method, acc, tokens.shift, tokens)
      end
    end

    def base(hash, key, tokens) # recursive
      hash.empty? && hash = { columns: [], associations: recursive_hash }
      if tokens.empty?
        # base case
        hash[:columns] << key
      else
        # recursive case
        # hash[:associations] ||= {}
        hash[:associations][key] = base(hash[:associations][key], tokens.shift, tokens)
      end
      hash
    end

    def json_params(hash, key, tokens)
      hash.empty? && hash = { only: [], methods: [], include: recursive_hash }
      if tokens.empty?
        # base case
        hash[:methods] << key
      else
        # recursive case
        # hash[:associations] ||= {}
        hash[:include][key] = json_params(hash[:include][key], tokens.shift, tokens)
      end
      hash
    end

    def recursive_hash
      func = ->(h, k) { h[k] = Hash.new(&func) }
      # This hash assigns a new key
      Hash.new(&func)
    end
  end
end
