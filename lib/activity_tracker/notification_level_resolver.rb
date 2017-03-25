module ActivityTracker
  class NotificationLevelResolver
    def initialize(activities = [])
      @activities = activities
      @notification_setting_repository = NotificationSettingRepository.new

      @levels_map = { }
      prefetch_levels
    end

    def perform
      @activities.map do |activity, receivers|
        type_string = activity.activity_type
        type_obj = ActivityTypeRepository.instance.get(type_string)

        if type_obj.skip_sender && activity.sender && !receivers.count.zero?
          receivers.reject! { |r| r.id == activity.sender_id }
        end

        receivers.map! do |r|
          level = @levels_map[activity.activity_type][r.id]

          next if level == ActivityTracker::NotificationLevels::DISABLED

          [r, level]
        end.compact!

        [activity, receivers]
      end
    end

    protected

    def prefetch_levels
      to_fetch = {}

      @activities.each do |activity, receivers|
        type_string = activity.activity_type

        to_fetch[type_string] ||= []
        to_fetch[type_string] += receivers.map(&:id)
        to_fetch[type_string].uniq!
      end

      to_fetch.each do |type_string, receiver_ids|
        type_obj = ActivityTypeRepository.instance.get(type_string)
        type_level = type_obj.level

        settings = @notification_setting_repository.get_for_user_ids(receiver_ids, type_string).to_a

        @levels_map[type_string] = Hash[*settings.map { |s| [s.user_id, s.level] }.flatten]
        receiver_ids.each { |rid| @levels_map[type_string][rid] ||= type_level }
      end
    end
  end
end
