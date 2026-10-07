class CreateConsents < ActiveRecord::Migration[8.1]
  def change
    create_table :consents do |t|
      t.references :citizen, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
       t.datetime :granted_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :revoked_at

      t.timestamps
    end
     add_index :consents, [ :citizen_id, :service_id ], unique: true
  end
end
