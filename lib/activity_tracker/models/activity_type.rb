module ActivityTracker
  class ActivityType
    def initialize(params = {}, &block)
      @batchable = true
      @skip_sender = true
      @level = NotificationLevels::EMAIL

      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end

      instance_eval(&block) if block

      freeze
    end

    def name(val = nil)
      if val.nil?
        instance_variable_get(:@name)
      else
        instance_variable_set(:@name, val.to_sym)
      end
    end

    [
      :metadata_fields, :to_text, :to_html, :batchable, :skip_sender, :level,
      :namespace, :label, :description, :no_notifications
    ].each do |field|
      define_method field do |val = nil, &block|
        var_name = "@#{field}"

        if val.nil? && !block
          instance_variable_get(var_name)
        else
          instance_variable_set(var_name, block || val)
        end
      end
    end
  end
end
