require('sqlite3')

module Selection
  def find id
    row = connection.get_first_row(<<-SQL)
      SELECT #{columns.join(',')} FROM #{table}
      WHERE id = #{id};
    SQL

    data = Hash[columns.zip(row)]
    new(data)
  end

  def find_by attribute, value
    objects = []
    command = <<-SQL
      SELECT * FROM #{table}
      WHERE #{attribute} = #{value};
    SQL
    connection.execute(command) { |row|
      objects.push(new(Hash[columns.zip(row)]))
    }
    objects
  end
end
