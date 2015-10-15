class PostsController < ApplicationController
  before_filter :authenticate_admin!
end