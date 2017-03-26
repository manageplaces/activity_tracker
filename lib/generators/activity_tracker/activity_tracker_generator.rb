module ActivityTracker
  module Generators
    class ActivityTrackerGenerator < Rails::Generators::Base
      Rails::Generators::ResourceHelpers

      source_root File.expand_path('../templates', __FILE__)

      argument :activity_class,
               type: :string,
               default: 'Activity',
               banner: 'Activity class name'

      argument :notification_batch_class,
               type: :string,
               default: 'NotificationBatch',
               banner: 'NotificationBatch class name'

      argument :notification_class,
               type: :string,
               default: 'Notification',
               banner: 'Notification class name'

      argument :notification_setting_class,
               type: :string,
               default: 'NotificationSetting',
               banner: 'NotificationSetting class name'

      argument :user_class,
               type: :string,
               default: 'User',
               banner: 'User class name'

      namespace :activity_tracker

      hook_for(:orm, required: true) do |invoked|
        invoke invoked, [
          'activity_tracker_models',
          activity_class,
          notification_batch_class,
          notification_class,
          notification_setting_class,
          user_class
        ]
      end

      desc 'Generates the required models and migration files.'

      def create_initializer
        template 'initializer.rb.erb', 'config/initializers/activity_tracker.rb'
      end
    end
  end
end
