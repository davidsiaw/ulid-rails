require "base32/crockford"

module ULID
  module Rails
    module Formatter
      def self.format(val)
        if defined?(ActiveRecord::ConnectionAdapters::MysqlAdapter) &&
           ActiveRecord::Base.connection.instance_of?(
             ActiveRecord::ConnectionAdapters::MysqlAdapter
           )
          val.length == 32 ? Base32::Crockford.encode(val.hex) : val
        elsif defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) &&
              ActiveRecord::Base.connection.instance_of?(
                ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
              )
          if val.length == 16
            Base32::Crockford.encode(val.unpack('H*')[0].to_i(16))
          else
            Base32::Crockford.encode(val.delete('-').to_i(16))
          end
        end
      end

      def self.unformat(val)
        if defined?(ActiveRecord::ConnectionAdapters::MysqlAdapter) &&
           ActiveRecord::Base.connection.instance_of?(
             ActiveRecord::ConnectionAdapters::MysqlAdapter
           )
          Base32::Crockford.decode(val).to_s(16).rjust(32, '0')
        elsif defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) &&
              ActiveRecord::Base.connection.instance_of?(
                ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
              )

          [Base32::Crockford.decode(val).to_s(16).rjust(32, '0')].pack('H*')
        end
      end
    end
  end
end
