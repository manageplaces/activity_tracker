ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name

    t.timestamps
  end

  create_table :activity_batches do |t|
    t.integer :reciever_id, null: false, required: true, index: true
    t.datetime :created_at, null: false, required: true
    t.timestamp :last_activity, required: true, null: false
    t.boolean :is_closed, required: true, null: false, default: false
    t.boolean :is_read, required: true, null: false, default: false
    t.boolean :is_sent, required: true, null: false, default: false
  end

  create_table :activities do |t|
    t.string :type, required: true, null: false
    t.integer :sender_id
    t.references :subject, polymorphic: true
    t.datetime :created_at, null: false, required: true
  end

  create_table :activities_activity_batches do |t|
    t.belongs_to :activities, required: true, null: false, index: true
    t.belongs_to :activity_batches, required: true, null: false, index: true
  end

  add_foreign_key :activity_batches, :users, column: :receiver_id, on_delete: :cascade
  add_foreign_key :activities, :users, column: :sender_id, on_delete: :cascade
end
