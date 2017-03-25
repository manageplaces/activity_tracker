module ActivityTracker
  class NotificationLevelResolver
    def initialize(activities = [])
      @activities = activities
      @notification_setting_repository = NotificationSettingRepository.new
    end

    def perform
      @activities.map do |activity, receivers|
        type_string = activity.activity_type
        type_obj = ActivityTypeRepository.instance.get(type_string)

        if type_obj.skip_sender && activity.sender && !receivers.count.zero?
          receivers.reject! { |r| r.id == activity.sender_id }
        end

        receivers.map! do |r|
          level = @notification_setting_repository.get(r, type_string).try(:level)
          level ||= type_obj.level

          next if level == ActivityTracker::NotificationLevels::DISABLED

          [r, level]
        end.compact!

        [activity, receivers]
      end
    end
  end
end
