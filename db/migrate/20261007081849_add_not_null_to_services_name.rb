class AddNotNullToServicesName < ActiveRecord::Migration[8.1]
  def change
    change_column_null :services, :name, false
  end
end
