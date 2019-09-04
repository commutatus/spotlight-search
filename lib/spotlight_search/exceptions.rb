module SpotlightSearch
  module Exceptions
    class InvalidColumns < StandardError
      def initialize(columns: [])
        message = 'Invalid columns found: ' + columns.map(&:to_s).join(', ')
        super(message)
      end
    end

    class InvalidValue < StandardError; end
  end
end
