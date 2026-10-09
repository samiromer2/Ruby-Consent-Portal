class AddRevokedAtIndexToConsents < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :consents, :revoked_at, algorithm: :concurrently
  end
end
