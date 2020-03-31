class AddNearestToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :nearest, :float
  end
end
