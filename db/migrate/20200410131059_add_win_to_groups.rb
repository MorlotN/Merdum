class AddWinToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :win, :string
  end
end
