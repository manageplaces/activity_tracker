module ActivityTracker
  def batch(&block)
    b = Batcher.new(&block)

    b.process
  end
end
