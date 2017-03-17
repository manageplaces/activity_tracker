class ActivityBatch < ActiveRecord::Base
  has_and_belongs_to_many :activities, after_add: :update_last_activity

  belongs_to :receiver, class_name: 'User'

  validates_presence_of :receiver
  validates_inclusion_of :is_closed, in: [true, false]
  validates_inclusion_of :is_sent, in: [true, false]
  validates_inclusion_of :is_read, in: [true, false]

  before_validation :update_last_activity

  protected

  def update_last_activity(_activity = nil)
    self.last_activity = [
      _activity.try(:created_at), last_activity].compact.max || DateTime.now
  end
end

class Activity < ActiveRecord::Base
  has_and_belongs_to_many :activity_batches

  belongs_to :sender, class_name: 'User'
  belongs_to :subject
end

class User < ActiveRecord::Base
end

class Task < ActiveRecord::Base
  include ActivityTracker::HasActivities
end
