# app/models/blog.rb
class Blog < ApplicationRecord
  belongs_to :user, optional: true
end
