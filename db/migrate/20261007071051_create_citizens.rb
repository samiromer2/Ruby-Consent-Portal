class CreateCitizens < ActiveRecord::Migration[8.1]
  def change
    create_table :citizens do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.boolean :verified, null: false, default: false

      t.timestamps
    end
    add_index :citizens, :email, unique: true
  end
end
