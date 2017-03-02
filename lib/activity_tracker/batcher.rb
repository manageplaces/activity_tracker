module ActivityTracker
  class Batcher
    def initialize(*options, &block)
      @options = options
      @block = block

      @activity_repository = ActivityRepository.new
      @batch_repository = BatchRepository.new
    end

    def process
      @collector = CollectorRepository.instance.get

      begin
        @block.call

        @activites = @collecor.activites

        filter_activities

        insert_activities
      rescue
        return false
      ensure
        CollectorRepository.instance.clear
      end

      true
    end

    protected

    def filter_activities
      # TODO
    end

    def insert_activities
      # TODO
    end
  end
end
