require_relative('utility')
require_relative('schema')
require_relative('persistence')
require_relative('selection')
require_relative('connection')
require_relative('collection')

module BlocRecord
  class Base
    include(Persistence)
    extend(Selection)
    extend(Schema)
    extend(Connection)
    extend(Collection)

    def initialize options={}
      options = BlocRecord::Utility.convert_keys(options)

      self.class.columns.each { |col|
        self.class.send(:attr_accessor, col)
        self.instance_variable_set("@#{col}", options[col])
      }
    end

    # Delegate find_by_* method calls to find_by.
    def self.method_missing method, value
      column = /find_by_(.+)/.match(method.to_s)[1]
      if column
        find_by(column, value)
      else
        raise NoMethodError
      end
    end

    def method_missing method, value
      column = /update_(.+)/.match(method.to_s)[1]
      if column
        self.class.update(id, column => value)
      else
        raise NoMethodError
      end
    end
  end
end
