class Authentication::SessionsController < Devise::SessionsController
  respond_to :json
end