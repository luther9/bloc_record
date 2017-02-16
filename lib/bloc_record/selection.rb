require('sqlite3')

module Selection
  def find *ids
    if ids.length == 1
      find_one(ids.first)
    else
      rows = connection.execute(<<-SQL)
        SELECT #{columns.join(',')} FROM #{table}
        WHERE id IN (#{ids.join(',')});
      SQL

      rows_to_array(rows)
    end
  end

  def find_one id
    row = connection.get_first_row(<<-SQL)
      SELECT #{columns.join(',')} FROM #{table}
      WHERE id = #{id};
    SQL

    do
      init_object_from_row(row)
    rescue ArgumentError
      raise ArgumentError.new("id #{id} not found")
    end
  end

  def find_by attribute, value
    row = connection.get_first_row(<<-SQL)
      SELECT #{columns.join(',')} FROM #{table}
      WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
    SQL

    do
      init_object_from_row(row)
    rescue ArgumentError
      raise ArgumentError.new("No record with #{attribute} = #{value}")
    end
  end

  def take num=1
    if num > 1
      rows = connection.execute(<<-SQL)
        SELECT #{columns.join(',')} FROM #{table}
        ORDER BY random()
        LIMIT #{num};
      SQL

      rows_to_array(rows)
    else
      take_one
    end
  end

  def take_one
    row = connection.get_first_row(<<-SQL)
      SELECT #{columns.join(',')} FROM #{table}
      ORDER BY random()
      LIMIT 1;
    SQL

    do
      init_object_from_row(row)
    rescue ArgumentError
      raise ArgumentError.new("No records in table")
    end
  end

  def first
    row = connection.get_first_row(<<-SQL)
      SELECT #{columns.join(',')} FROM #{table}
      ORDER BY id
      ASC LIMIT 1;
    SQL

    do
      init_object_from_row(row)
    rescue ArgumentError
      raise ArgumentError.new("No records in table")
    end
  end

  def last
    row = connection.get_first_row(<<-SQL)
      SELECT #{columns.join(',')} FROM #{table}
      ORDER BY id
      DESC LIMIT 1;
    SQL

    do
      init_object_from_row(row)
    rescue ArgumentError
      raise ArgumentError.new("No records in table")
    end
  end

  def all
    rows = connection.execute(<<-SQL)
      SELECT #{columns.join(',')} FROM #{table};
    SQL

    rows_to_array(rows)
  end

  private

  def init_object_from_row row
    if row
      data = Hash[columns.zip(row)]
      new(data)
    else
      raise ArgumentError
    end
  end

  def rows_to_array rows
    rows.map { |row|
      new(Hash[columns.zip(row)])
    }
  end
end
