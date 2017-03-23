require 'activity_tracker/railtie' if defined?(Rails)

require 'activity_tracker/configuration'

require 'activity_tracker/models/activity_type'

require 'activity_tracker/repositories/activity_repository'
require 'activity_tracker/repositories/activity_type_repository'
require 'activity_tracker/repositories/notification_batch_repository'
require 'activity_tracker/repositories/collector_repository'

require 'activity_tracker/batch'
require 'activity_tracker/batcher'
require 'activity_tracker/collector'

require 'activity_tracker/track_activity'
require 'activity_tracker/has_activities'
require 'activity_tracker/define_activity'

require 'activity_tracker/version'

module ActivityTracker
end
