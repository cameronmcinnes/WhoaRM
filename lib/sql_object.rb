require_relative 'db_connection'
require_relative 'associatable'
require_relative 'searchable'
require_relative 'validatable'
require_relative 'errors/not_saved'
require 'active_support/inflector'

class SQLObject
  extend Associatable
  extend Searchable
  include Validatable

  # enables attr_accessors of the class instance variable validator
  class << self
    attr_accessor :validator
  end

  def self.columns
    return @columns if @columns

    table_info = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    @columns = table_info.first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column_name|
      define_method(column_name) do
        # self is instance  of class (inside define method)
        self.attributes[column_name]
      end

      setter = "#{column_name}="

      define_method(setter.to_sym) do |val|
        self.attributes[column_name] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    self.parse_all(results)
  end

  def self.parse_all(results)
    results.map { |params| self.new(params) }
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL

    return nil if results.empty?

    self.parse_all(results).first
  end


  def self.pluck(attr_name)
    resultArr = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.#{attr_name}
      FROM
        #{table_name}
    SQL

    resultArr.reduce([]) { |result, hash| result.concat(hash.values) }
  end

  def initialize(params = {})
    @errors = Hash.new { |h, k| h[k] = [] }

    params.each do |attr_name, value|
      attr_sym = attr_name.to_sym
      unless self.class.columns.include?(attr_sym)
        raise "unknown attribute '#{attr_name}'"
      end

      self.send("#{attr_sym}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |attr_name| send(attr_name) }
  end

  def insert
    col_names = self.class.columns.drop(1).join(",")
    question_marks = ["?"] * (self.class.columns.length - 1)
    q_mark_str = question_marks.join(",")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{q_mark_str})
    SQL

    @attributes[:id] = DBConnection.last_insert_row_id
  end

  def update
    set = self.class.columns.drop(1).map { |colname| "#{colname} = ?"  }

    DBConnection.execute(<<-SQL, *attribute_values.drop(1), self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set.join(",")}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

  def save
    if valid?
      id.nil? ? insert : update
    else
      false
    end
  end

  def save!
    if valid?
      id.nil? ? insert : update
    else
      msg = "validations failed: \n #{self.errors}"
      raise RecordNotSaved.new(self.errors), msg
    end
  end
end
