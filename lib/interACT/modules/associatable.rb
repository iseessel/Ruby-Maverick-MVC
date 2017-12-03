require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    return "humans" if @class_name == "Human"
    @class_name.camelcase.downcase.pluralize
  end

end

# BelongsTo and HasManyOptions
# is in charge of calculating foreign_key, primary_key, and class_name

class BelongsToOptions < AssocOptions

  def initialize(name, options = {})
    @foreign_key ="#{name.downcase}_id".to_sym
    @primary_key = :id
    @class_name = name.capitalize.to_s

    options.each do |instance_variable, value|
      instance_variable_set("@#{instance_variable}", value)
    end
  end

end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key ="#{self_class_name.downcase}_id".to_sym
    @primary_key = :id
    @class_name = name.to_s.singularize.camelcase

    options.each do |instance_variable, value|
      instance_variable_set("@#{instance_variable}", value)
    end
  end

end

module Associatable

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      options.model_class.where(id: self.id).first
    end

  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options.model_class.where(options.foreign_key => self.id)
    end
  end

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      data = DBConnection.execute(<<-SQL, self.id)
        SELECT
          #{source_options.table_name}.*
        FROM
          #{through_options.table_name}
        JOIN
          #{source_options.table_name}
        ON
          #{through_options.table_name}.#{source_options.foreign_key.to_s} =
          #{source_options.table_name}.#{source_options.primary_key.to_s}
        WHERE
          #{through_options.table_name}.id = ?
      SQL
      source_options.model_class.parse_all(data).first
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end
