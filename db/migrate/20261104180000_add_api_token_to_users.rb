class AddApiTokenToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :api_token, :string

    User.reset_column_information
    User.find_each do |user|
      user.update_column(:api_token, SecureRandom.base58(24))
    end

    change_column_null :users, :api_token, false
    add_index :users, :api_token, unique: true
  end

  def down
    remove_column :users, :api_token
  end
end
