class CreateCitizens < ActiveRecord::Migration[8.1]
  def change
    create_table :citizens do |t|
      t.string :name
      t.string :email
      t.boolean :verified

      t.timestamps
    end
    add_index :citizens, :email, unique: true
  end
end
