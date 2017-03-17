module ActivityTracker
  class Batcher
    def initialize(options, &block)
      @options = options
      @block = block

      @activity_repository = ActivityRepository.new
      @activity_batch_repository = ActivityBatchRepository.new

      @collected_activities = []
    end

    def process
      return false unless @block

      @collector = CollectorRepository.instance.get

      begin
        @block.call


        filter_activities

        insert_activities
      rescue StandardError => e
        return false
      ensure
        CollectorRepository.instance.clear
      end

      true
    end

    protected

    def filter_activities
      activities = @collector.activities.to_a

      activities.each do |activity_params|
        receivers = activity_params[:receivers]
        activity_params.delete(:receivers)

        next unless receivers

        @collected_activities << [
          @activity_repository.factory(activity_params),
          receivers
        ]
      end
    end

    def insert_activities
      @collected_activities.each do |activity, receivers|
        @activity_repository.add(activity)
      end
    end
  end
end
