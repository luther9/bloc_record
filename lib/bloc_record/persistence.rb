require('sqlite3')
require_relative('schema')

module Persistence
  def self.included base
    base.extend(ClassMethods)
  end

  def save
    save!
  rescue false
  end

  def save!
    if !id
      self.id = self.class.
        create(BlocRecord::Utility.instance_variables_to_hash(self)).id
      BlocRecord::Utility.reload_obj(self)
      return true
    end

    fields = self.class.attributes.map { |col|
      "#{col}=#{BlocRecord::Utility.sql_strings(instance_variable_get("@#{col}"))}"
      }.join(',')

    self.class.connection.execute(<<-SQL)
      UPDATE #{self.class.table}
      SET #{fields}
      WHERE id = #{id};
    SQL

    true
  end

  def update_attribute attribute, value
    self.class.update(self.id, {attribute => value})
  end

  def update_attributes updates
    self.class.update(self.id, updates)
  end

  module ClassMethods
    def create attrs
      attrs = BlocRecord::Utility.convert_keys(attrs)
      attrs.delete('id')
      vals = attributes.map { |key|
        BlocRecord::Utility.sql_strings(attrs[key])
      }

      connection.execute(<<-SQL)
        INSERT INTO #{table} (#{attributes.join(',')})
        VALUES (#{vals.join(',')});
      SQL

      data = Hash[attributes.zip(attrs.values)]
      data['id'] = connection.execute('SELECT last_insert_rowid();')[0][0]
      new(data)
    end

    #7
    def update ids, updates
      updates = BlocRecord::Utility.convert_keys(updates)
      updates.delete('id')
      updates_array = updates.map { |key, value|
        "#{key}=#{BlocRecord::Utility.sql_strings(value)}"
      }

      #8
      where_clause = if ids.class == FixNum
                       "WHERE id = #{ids}"
                     elsif ids.class == Array
                       if ids.empty?
                         ''
                       else
                         "WHERE id IN (#{ids.join(',')})"
                       end
                     else
                       ''
                     end

      connection.execute(<<-SQL)
        UPDATE #{table}
        SET #{updates_array * ','} #{where_clause};
      SQL

      true
    end

    def update_all updates
      update(nil, updates)
    end
  end
end
