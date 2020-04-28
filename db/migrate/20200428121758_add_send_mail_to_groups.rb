class AddSendMailToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :send_mail, :boolean
  end
end
