require 'rails/generators/active_record'
require 'active_support/core_ext'

module ActiveRecord
  module Generators
    class ActivityTrackerGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      argument :activity_class,
               type: :string,
               default: 'Activity',
               banner: 'Activity class name'

      argument :activity_batch_class,
               type: :string,
               default: 'ActivityBatch',
               banner: 'ActivityBatch class name'

      argument :user_class,
               type: :string,
               default: 'User',
               banner: 'User class name'

      def generate_activity_model
        template 'activity.rb.erb', activity_model_path
      end

      def generate_activity_batch_model
        template 'activity_batch.rb.erb', activity_batch_model_path
      end

      def create_migrations
        migration_template 'migrations.rb.erb', migration_path
      end

      private

      def activity_model_path
        File.join('app', 'models', "#{activity_class.underscore.downcase}.rb")
      end

      def activity_batch_model_path
        File.join(
          'app',
          'models',
          "#{activity_batch_class.underscore.downcase}.rb"
        )
      end

      def activity_activity_batch_model_path
        filename = "#{activity_class.underscore.downcase}_"
        filename += "#{activity_batch_class.underscore.downcase}.rb"

        File.join('app', 'models', filename)
      end

      def migration_path
        File.join('db', 'migrate', "#{name}.rb")
      end
    end
  end
end
