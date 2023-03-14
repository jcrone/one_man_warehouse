class StaticController < ApplicationController
    layout "welcome", only: [:welcome]

    def dashboard
        @unpaid = Hour.where(status: Hour.statuses[:unpaid]).or(Hour.where(status: Hour.statuses[:processing]))
        @pagy, @todos =  pagy(Todo.all)
        @shipments = Shipment.where.not(status: Shipment.statuses[:delivered])
    end 
end