require "active_model/type"
require "ulid/rails/formatter"

module ULID
  module Rails
    class Type < ActiveModel::Type::Binary
      class Data < ActiveModel::Type::Binary::Data
        alias_method :hex, :to_s
      end

      def initialize(formatter = Formatter)
        @formatter = formatter
        super()
      end

      def cast(value)
        if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) &&
              ActiveRecord::Base.connection.instance_of?(
                ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
              )

          if value.is_a?(Data)
            Base32::Crockford.encode(value.to_s.unpack('H*')[0].to_i(16))
          elsif value&.encoding == Encoding::UTF_8 && value.include?('-')
            Base32::Crockford.encode(value.delete('-').to_i(16))
          elsif value&.encoding == Encoding::UTF_8
            value
          else
            super
          end
        else
          if value.is_a?(Data)
            @formatter.format(value.to_s)
          elsif value&.encoding == Encoding::ASCII_8BIT
            @formatter.format(value.unpack("H*")[0])
          else
            super
          end
        end

      end

      def serialize(value)
        return if value.nil?
        Data.new(@formatter.unformat(value))
      end
    end
  end
end
