class StaticController < ApplicationController
    layout "welcome", only: [:welcome]
end