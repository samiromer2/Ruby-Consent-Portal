class CreateConsentEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :consent_events do |t|
      t.references :consent, null: false, foreign_key: true, index: false
      t.references :user, foreign_key: true
      t.string :action, null: false
      t.datetime :created_at, null: false

      t.index [ :consent_id, :created_at ]
    end
  end
end
