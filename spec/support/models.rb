class NotificationBatch < ActiveRecord::Base
  include ActivityTracker::NotificationBatchModel
end

class Activity < ActiveRecord::Base
  include ActivityTracker::ActivityModel
end

class Notification < ActiveRecord::Base
  include ActivityTracker::NotificationModel
end

class NotificationSetting < ActiveRecord::Base
  include ActivityTracker::NotificationSettingModel
end

class User < ActiveRecord::Base
  def to_s
    name
  end
end

class Task < ActiveRecord::Base
  include ActivityTracker::HasActivities
end
