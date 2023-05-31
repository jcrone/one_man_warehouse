class Sync < ApplicationRecord
    enum :status, { completed: 0, pending: 1, syncing: 2 }
end
