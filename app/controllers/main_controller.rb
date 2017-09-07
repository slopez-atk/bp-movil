class MainController < ApplicationController
  before_action authenticate_user!, expect: [:home]
  def home
  end

  def dashboard

  end

  def home_creditos

  end
end
