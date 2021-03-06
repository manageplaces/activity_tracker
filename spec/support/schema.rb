ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name
    t.boolean :skip_notifications, required: true, default: false

    t.timestamps
  end

  create_table :tasks, force: true do |t|
    t.string :name

    t.timestamps
  end

  create_table :notification_batches do |t|
    t.belongs_to :receiver, null: false, required: true, index: true, foreign_key: true, on_delete: :cascade
    t.datetime :created_at, null: false, required: true
    t.timestamp :last_activity, required: true, null: false
    t.boolean :is_closed, required: true, null: false, default: false
    t.boolean :is_sent, required: true, null: false, default: false
  end

  create_table :activities do |t|
    t.string :activity_type, required: true, null: false
    t.belongs_to :sender, index: true, foreign_key: true, on_delete: :nullify
    t.belongs_to :scope, polymorphic: true, null: false, required: true
    t.belongs_to :resource, polymorphic: true, null: false, required: true
    t.boolean :is_hidden, required: true, default: false
    t.datetime :created_at, null: false, required: true
    t.text :metadata
  end

  create_table :notifications do |t|
    t.belongs_to :activity, required: true, null: false, index: true
    t.belongs_to :notification_batch, required: true, null: false, index: true
    t.boolean :is_read, required: true, null: false, default: false
    t.boolean :send_mail, required: true, null: false
  end

  add_column :users, :notification_settings, :text
end
