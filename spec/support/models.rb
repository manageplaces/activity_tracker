class NotificationBatch < ActiveRecord::Base
  include ActivityTracker::NotificationBatchModel
end

class Activity < ActiveRecord::Base
  include ActivityTracker::ActivityModel
end

class Notification < ActiveRecord::Base
  include ActivityTracker::NotificationModel
end

class User < ActiveRecord::Base
  include ActivityTracker::UserModel

  def to_s
    name
  end
end

class Task < ActiveRecord::Base
  include ActivityTracker::HasActivities
end
