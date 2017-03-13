require('sqlite3')
require('active_support/inflector')

module Associations
  def has_many(association)
    #1
    define_method(association) {
      #2
      rows = self.class.connection.execute(<<-SQL)
        SELECT * FROM #{association.to_s.singularize}
        WHERE #{self.class.table}_id = #{self.id};
      SQL

      #3
      class_name = association.to_s.classify.constantize
      collection = BlocRecord::Collection.new

      #4
      rows.each { |row|
        collection << class_name.new(Hash[class_name.columns.zip(row)])
      }

      #5
      collection
    }
  end

  def belongs_to(association)
    define_method(association) {
      association_name = association.to_s
      row = self.class.connection.get_first_row(<<-SQL)
        SELECT * FROM #{association_name}
        WHERE id = #{self.send(association_name + '_id')};
      SQL

      class_name = association_name.classify.constantize

      if row
        data = Hash[class_name.columns.zip(row)]
        class_name.new(data)
      end
    }
  end

  def has_one(association)
    define_method(association) {
      row = self.class.connection.get_first_row(<<-SQL)
        SELECT * FROM #{association}
        WHERE id = #{self.send(association.to_s + '_id')};
      SQL

      if row
        class_ = association.classify.constantize
        class_.new(Hash[class_.columns.zip(row)])
      end
    }
  end
end
