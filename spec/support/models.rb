class ActivityBatch < ActiveRecord::Base
  has_and_belongs_to_many :activities

  belongs_to :receiver, class_name: 'User'

  validates_presence_of :owner, :is_read, :is_sent

  before_save :update_last_activity

  protected

  def update_last_activity
    last_activity = DateTime.now
  end
end

class Activity < ActiveRecord::Base
  has_and_belongs_to_many :activity_batches

  belongs_to :sender, class_name: 'User'
  belongs_to :subject
end

class User < ActiveRecord::Base
end
