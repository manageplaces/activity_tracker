module ActivityTracker
  class ActivityType
    def initialize(params = {}, &block)
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end

      instance_eval(&block) if block

      freeze
    end

    [:name].each do |field|
      define_method field.to_sym do |val = nil|
        var_name = "@#{field}"

        if val.nil?
          instance_variable_get(var_name)
        else
          instance_variable_set(var_name, val)
        end
      end
    end
  end
end
