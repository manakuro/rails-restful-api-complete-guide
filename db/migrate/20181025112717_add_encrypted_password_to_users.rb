class AddEncryptedPasswordToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :encryped_password, :string
  end
end
