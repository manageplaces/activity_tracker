module ActivityTracker
  def self.batch(options = {}, &block)
    b = Batcher.new(options, &block)

    b.process
  end
end
