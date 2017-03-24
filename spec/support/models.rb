class NotificationBatch < ActiveRecord::Base
  has_many :notifications
  has_many :activities, after_add: :update_last_activity, through: :notifications

  belongs_to :receiver, class_name: 'User'

  validates_presence_of :receiver
  validates_inclusion_of :is_closed, in: [true, false]
  validates_inclusion_of :is_sent, in: [true, false]

  before_validation :update_last_activity

  protected

  def update_last_activity(_activity = nil)
    self.last_activity = [
      _activity.try(:created_at), last_activity].compact.max || DateTime.now
  end
end

class Activity < ActiveRecord::Base
  has_many :notifications
  has_many :notification_batches, through: :notifications

  belongs_to :sender, class_name: 'User'
  belongs_to :scope, polymorphic: true

  validates_presence_of :activity_type

  def type
    activity_type ? ::ActivityTracker::ActivityTypeRepository.get(activity_type) : nil
  end
end

class Notification < ActiveRecord::Base
  belongs_to :activity
  belongs_to :notification_batch
end

class NotificationSetting < ActiveRecord::Base
  belongs_to :user

  validates_inclusion_of :level, in: ActivityTracker::NotificationLevels::TYPES
  validates_presence_of :activity_type, :level, :user
  validates_uniqueness_of :activity_type, scope: :user_id
end

class User < ActiveRecord::Base
end

class Task < ActiveRecord::Base
  include ActivityTracker::HasActivities
end
