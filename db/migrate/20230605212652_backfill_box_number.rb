class BackfillBoxNumber < ActiveRecord::Migration[7.0]
  def change
    disable_ddl_transaction
    @boxes = Box.all
    @boxes.each do |box|
      box.box_number = box.number.to_i
      box.save
      sleep(0.01) # throttle
    end

  end
end
