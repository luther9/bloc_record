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

  def find_each options={}
    find_in_batches(options) { |batch|
      batch.each { |row|
        yield(row)
      }
    }
  end

  def find_in_batches options={}
    options = {start: 0, batch_size: 1000}.merge(options)
    rows = connection.execute(<<-SQL)
      SELECT * FROM #{table};
    SQL
    start = options[:start]
    batch_size = options[:batch_size]
    batch_n = 0
    while start < rows.size
      yield(rows_to_array(rows[start, batch_size]), batch_n)
      start += batch_size
      batch_n += 1
    end
  end

  def where *args
    if args.count > 1
      expression = args.shift
      params = args
    else
      case args.first
      when String
        expression = args.first
      when Hash
        expression_hash = BlocRecord::Utility.convert_keys(args.first)
        expression = expression_hash.map { |key, value|
          "#{key}=#{BlocRecord::Utility.sql_strings(value)}"
        }.join(' AND ')
      end
    end

    sql = <<-SQL
      SELECT #{columns.join(',')} FROM #{table}
      WHERE #{expression};
    SQL

    rows = connection.execute(sql, params)
    rows_to_array(rows)
  end

  def order *args
    ordering = []
    args.each { |spec|
      case spec
      when String
        ordering.push(spec)
      when Symbol
        ordering.push(spec.to_s)
      when Hash
        spec.each_pair { |column, scending|
          ordering.push("#{column.to_s} #{scending.to_s}")
        }
      end
    }

    rows_to_array(connection.execute(<<-SQL))
      SELECT * FROM #{table}
      ORDER BY #{ordering.join(',');
    SQL
  end

  def join *args
    if args.count > 1
      joins = args.map { |arg|
        "INNER JOIN #{arg} ON #{arg}.#{table}_id = #{table}.id"
      }.join(' ')
      rows = connection.execute(<<-SQL)
        SELECT * FROM #{table} #{joins}
      SQL
    else
      case args.first
      when String
        rows = connection.execute(<<-SQL)
          SELECT * FROM #{table} #{BlocRecord::Utility.sql_strings(arg)};
        SQL
      when Symbol
        rows = connection.execute(<<-SQL)
          SELECT * FROM #{table}
          INNER JOIN #{arg} ON #{arg}.#{table}_id = #{table}.id
        SQL
      end
    end

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
