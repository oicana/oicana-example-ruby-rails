class HomeController < ApplicationController
  def index
    render html: 'Visit the swagger documentation at <a href="/api-docs">/api-docs</a>'.html_safe
  end
end
