require('sqlite3')
require('pg')

module BlocRecord
  def self.connect_to filename, platform
    if File.exist?(filename)
      @database_filename = filename
      @database_type = case platform
                       when :sqlite3
                         SQLite3::Database
                       when :pg
                         PGDatabase
                       else
                         raise 'Invalid platform'
                       end
    else
      raise "File doesn't exist"
    end
  end

  def self.database_filename
    @database_filename
  end

  def self.database_type
    @database_type
  end

  private

  # A wrapper for pg that emulates the sqlite3 interface.
  class PGDatabase
    def initialize filename
      @db = PG.connect(dbname: filename)
    end

    def execute statement
      @db.exec(statement).values
    end

    def get_first_row statement
      execute(statement)[0]
    end

    def table_info table
      result = @db.exec("SELECT * FROM #{table};")
      result.fields.each_index { |i|
        yield {'name' => result.fields[i], 'type' => result.ftype(i)}
      }
    end
  end
end
