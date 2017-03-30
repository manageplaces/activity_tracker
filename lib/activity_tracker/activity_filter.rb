module ActivityTracker
  class ActivityFilter
    def initialize(*args)
      raise ArgumentError if args.count > 1

      @reject_all = false
      @filters = {}

      return if args.count == 0

      arg = args[0]

      if arg.is_a?(TrueClass) || arg.is_a?(FalseClass)
        init_bool_arg(arg)
      elsif arg.is_a?(Symbol)
        init_symbol_arg(arg)
      elsif arg.is_a?(String)
        init_symbol_arg(arg.to_sym)
      elsif arg.is_a?(Array)
        init_array_arg(arg)
      elsif arg.is_a?(Hash)
        init_hash_arg(arg)
      else
        raise ArgumentError
      end
    end

    def match?(activity)
      return false if @reject_all
      return true if @filters.count.zero?

      @filters.each do |key, value|
        return false unless value.include?(activity[key])
      end

      return true
    end

    private

    def init_bool_arg(arg)
      @reject_all = true unless arg
    end

    def init_symbol_arg(arg)
      @filters[:activity_type] = [arg]
    end

    def init_array_arg(arg)
      @filters[:activity_type] = arg
    end

    def init_hash_arg(arg)
      arg.each { |key, val| arg[key] = val.is_a?(Array) ? val : [val] }
      @filters = arg
    end
  end
end
