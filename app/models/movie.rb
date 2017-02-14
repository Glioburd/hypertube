class Movie < ApplicationRecord
	has_many :translates
	has_many :comments
	has_many :views
end