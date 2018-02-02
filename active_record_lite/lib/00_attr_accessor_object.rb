# require "byebug"

class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |ivar_name|

      getter = "@#{ivar_name}"

      define_method(ivar_name) do
        self.instance_variable_get(getter)
      end

      setter = "#{ivar_name}="
      ivar_name_w_at = "@#{ivar_name}"

      define_method(setter.to_sym) do |val|
        self.instance_variable_set(ivar_name_w_at, val)
      end
    end
  end
end
