module ActivityTracker
  class CollectorRepository
    def initialize
      @collectors = {}
    end

    def get(thread_id = Thread.current.object_id)
      @collectors[thread_id] ||= ::ActivityTracker::Collector.new
    end

    def exists?(thread_id = Thread.current.object_id)
      @collectors.include?(thread_id)
    end

    def clear(thread_id = Thread.current.object_id)
      @collectors.delete(thread_id)
    end

    def self.instance
      @instance ||= CollectorRepository.new
    end
  end
end
