require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'

class SQLObject

  #Upon initialization, create the appropriate attributes hash for
  #the SQL instance.
  def initialize(params = {})
    params.each do |column_name, value|
      unless self.class.columns.include?(column_name.to_sym)
        raise  "unknown attribute '#{column_name}'"
      end
      self.send("#{column_name}=", value)
    end
  end

  # DBConnection's #execute2 returns an array, whos first element
  # is a list of the column names.
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL
      Select
        *
      FROM
        #{self.table_name}
    SQL
    ).first
    @columns.map(&:to_sym)
  end

  def self.finalize!

  # Defining getter/setter methods for each column name
    self.columns.each do |column_sym|
      define_method(column_sym) { attributes[column_sym] }
      define_method("#{column_sym}=") { |value| attributes[column_sym] = value}
    end
  end

  def self.table_name=(table_name = @table)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    results_hash ||= DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    self.parse_all(results_hash)
  end

  def self.find(id_num)
    datum = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = #{id_num}
    SQL
    if datum.empty?
      return nil
    else
      self.new(datum.first)
    end
  end

  # seperates instance variables associated
  # with the database and those that are not.
  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |column_name|
      @attributes[column_name]
    end
  end

  def save
    self.id.nil? ? self.insert : self.update
  end

  private

  #Create an array of new SQL objects from the result of the queery.
  def self.parse_all(results)
    parsed = results.map do |result|
      self.new(result)
    end
  end

  def insert
    columns = self.class.columns
    col_names = columns.join(",")
    question_marks = (["?"] * (columns.length)).join(",")
    DBConnection.execute(<<-SQL, *self.attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    columns = self.class.columns
    set_columns = columns.map do |column|
      column.to_s + "=?"
    end.join(",")

    #NB: The indeces of set_columns and self.attribute_values match up,
    # because they are both calling self.class.columns.

    DBConnection.execute(<<-SQL, *self.attribute_values, self.id)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_columns}
    WHERE
      id = ?
    SQL
  end
end
