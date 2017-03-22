module ActivityTracker
  module Generators
    class ActivityTrackerGenerator < Rails::Generators::Base
      Rails::Generators::ResourceHelpers

      source_root File.expand_path('../templates', __FILE__)

      argument :activity_class,
               type: :string,
               default: 'Activity',
               banner: 'Activity class name'

      argument :activity_batch_class,
               type: :string,
               default: 'ActivityBatch',
               banner: 'ActivityBatch class name'

      argument :user_activity_class,
               type: :string,
               default: 'UserActivity',
               banner: 'UserActivity class name'

      argument :user_class,
               type: :string,
               default: 'User',
               banner: 'User class name'

      namespace :activity_tracker

      hook_for(:orm, required: true) do |invoked|
        invoke invoked, [
          'activity_tracker_models',
          activity_class,
          activity_batch_class,
          user_activity_class,
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
