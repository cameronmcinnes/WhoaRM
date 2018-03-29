# GoRM: Good Object-relational mapping for Ruby
***
GoRM connects classes to relational database tables to establish an almost zero-configuration persistence layer for applications. The core of the library is the SQLObject class that maps between a child class and a database table. These classes function as model in the MVC design pattern. GoRM leverages the module pattern to keep code dry and extends querying, validation, and association functionality to models.

GoRM values convention over configuration and makes use of metaprogramming to intelligently generate method names. GoRM allows customization of names but is most powerful when used in conjunction with strong naming conventions.

## Using this project

To demo GoRM clone this repo locally, run bundle install, and open pry. From there you can query the database. Be sure to try out associations [three tables] including `#belongs_to`, `#has_many`, and `#has_one_through`. Try initializing new SQLObjects and testing whether or not they're valid with `#valid?` and `#errors`. Inside the `demo.rb` file you can change validations (try `numericality: true`). Also try out querying, including pluck and lazy where queries to see them return Relation objects until valid array methods are called upon them.

## Features
In the following code is the Team class is automatically mapped to the existing database table of the same name, pluralized.

```` ruby
class Team < SQLObject
  finalize!
end
````
Database

```` SQL
CREATE TABLE teams (
  id INTEGER PRIMARY KEY,
  team_name VARCHAR(255) NOT NULL,
  team_color VARCHAR(255)
);
````

This defines getter and setter methods for each column in the teams table: `Team#team_name` `Team#team_color=` `Team#team_color` `Team#team_color=`

By instantiating a new Team object, using the setter methods and calling `Team#save`, a new row in the teams table will be created. We can also update an existing row with `Team#save`.

### Associations

With very little explicit declaration GoRM models can be connected to each other through associations. The following code will create an instance method Contestant#team that queries the teams table matching the foreign key to the contestants id. If no foreign key is specified GoRM will automatically use the column in the source table that matches the `target_table.id`.

```` Ruby
class Contestant < SQLObject
  belongs_to :team
  finalize!
end
````

GoRM also enables `has_many` and `has_one_through` associations. In the case of `has_one_through` GoRM performs a join on the through and source tables specified.

### Lazy and Stackable Queries

GoRM implements a relation class to allow lazy, stackable querying to minimize expensive and unnecessary database hits. The searchable module extends `SQLObject#where` to model classes. `SQLObject#where` can take a query hash or string and returns an array like `Relation` object that stores the parameters of the query until the results are needed. The relation class uses method_missing to catch any array methods called upon a relation object.

```` ruby
def method_missing(method_name, *args, &blk)
  if Array.instance_methods.include?(method_name)
    execute_query.send(method_name, *args, &blk)
  else
    super
  end
end
````

When any array instance method is called the relation object will execute the query, parse the results into an array of model objects, and perform the array instance method on the resulting array.

Where queries can be chained onto the relation object and any additional parameters are merged onto the existing params.


### Validations

The `Validatable` module extends validation functionality to GoRM model classes. Validations are automatically run on `SQLObject#save` to avoid expensive DB rollback and any associated service interruptions.

Validations can also be run on any instance of a model class with `SQLObject#valid?`. If a model object fails validation, either on save or explicit validation, error messages will be stored in an errors hash instance variable keyed under the column names. `SQLObject#save!` will raise a custom error on failed validations and `SQLObject#save` will simply return false and populate the errors hash.

```` Ruby
class Contestant < SQLObject
  validates :lname, uniqueness: true, presence: true
  validates :fname, :enthusiasm, presence: true
  validates :enthusiasm, numericality: true

  belongs_to :team
  finalize!
end
````

Database:

```` SQL
CREATE TABLE contestants (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  enthusiasm INTEGER NOT NULL,
  team_id INTEGER,

  FOREIGN KEY(team_id) REFERENCES team(id)
);
````

This was achieved by implementing a `Validator` class. A new instance of this validator class is instantiated when an GoRM model class is defined with validations and is saved as a class instance variable.

```` ruby
module Validatable
  ...
  private
  module ClassMethods
    def validates(*attr_names, options)
      self.validator ||= Validator.new(self)
      self.validator.add_validations(*attr_names, options)
    end
  end
end
````

```` ruby
def uniqueness(bool, new_instance, attr_name)
  attr_value = new_instance.send(attr_name)

  if new_instance.id.nil?
    col_vals = sql_object_class.pluck(attr_name)
  else
    col_vals = sql_object_class.where("NOT id = #{new_instance.id}").
      pluck(attr_name)
  end

  bool != col_vals.include?(attr_value)
end
````

Currently GoRM supports presence, uniqueness, and numericality validations but implementing further validation options is trivial.

### Pluck

GoRM features `SQLObject#pluck` which circumvents unneeded model creation and returns an array of column values from the related table. `#pluck` can also be chained after `SQLObject#where`

## Future Directions
* Add `has_many_through` associations
* Add includes for pre-fetching associations
* Add custom joins for more powerful querying
* Add polymorphic associations
