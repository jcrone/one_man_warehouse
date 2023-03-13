class Todo < ApplicationRecord

    enum :todo_status, { new_item: 0, waiting_on_info: 1, completed: 2 }
end
