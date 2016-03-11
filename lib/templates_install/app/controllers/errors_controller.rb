class ErrorsController < ApplicationController

  def routing_error
    render 'errors/error404', status: 404
  end
end
