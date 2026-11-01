class AddUserToCitizens < ActiveRecord::Migration[8.1]
  def up
    add_reference :citizens, :user, foreign_key: true, index: { unique: true }

    # Citizens created before accounts have no user. Each citizen belongs to one user.
    execute <<~SQL
      DELETE FROM consents
      WHERE citizen_id IN (SELECT id FROM citizens WHERE user_id IS NULL)
    SQL
    execute "DELETE FROM citizens WHERE user_id IS NULL"

    change_column_null :citizens, :user_id, false
  end

  def down
    remove_reference :citizens, :user, foreign_key: true
  end
end
