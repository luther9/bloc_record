require('sqlite3')
require_relative('utility')

module Schema
  def table
    BlocRecord::Utility.underscore(name)
  end

  def schema
    if !@schema
      @schema = {}
      connection.table_info(table) { |col|
        @schema[col['name']] = col['type']
      }
    end
    @schema
  end

  def columns
    schema.keys
  end

  def attributes
    columns - ['id']
  end

  def count
    connection.execute(<<-SQL)[0][0]
      SELECT COUNT(*) FROM #{table}
    SQL
  end
end
