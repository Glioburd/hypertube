bundle install
rake db:migrate
whenever --set environment='development'
npm install api
node api/bin/www &
rails s
