require "base32/crockford"

module ULID
  module Rails
    module Formatter
      def self.format(v)
        if defined?(ActiveRecord::ConnectionAdapters::MysqlAdapter) &&
          ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters::MysqlAdapter)
          v.length == 32 ? Base32::Crockford.encode(v.hex) : v
        elsif defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) && 
          ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
          Base32::Crockford.encode(v.delete('-').to_i(16))
        end
      end

      def self.unformat(v)
        if defined?(ActiveRecord::ConnectionAdapters::MysqlAdapter) &&
          ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters::MysqlAdapter)
          Base32::Crockford.decode(v).to_s(16).rjust(2, '0')
        elsif defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) && 
          ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
          [Base32::Crockford.decode(v).to_s(16).rjust(2, '0')].pack('H*')
        end
      end
    end
  end
end
