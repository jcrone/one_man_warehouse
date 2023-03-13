class ChangePayDateFormateInHours < ActiveRecord::Migration[7.0]
  def change
    change_column :hours, :pay_date, :datetime
  end
end
