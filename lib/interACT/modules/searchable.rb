require_relative '../db_connection'
require_relative '../sql_object'

module Searchable

  def where(params)
    where_line = params.map { |k,v| "#{k} = ?" }.join("AND ")
    where_conditions = params.map { |_,v| v}

    results_hash = DBConnection.execute(<<-SQL, *where_conditions)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL

    results_hash.map { |result| self.new(result)} #will this preform O(n) queeries?
  end
end

class SQLObject
  extend Searchable
end
