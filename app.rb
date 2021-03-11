require 'sinatra'
require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'
require './lib/book'
require './databases/db'
also_reload 'lib/**/*.rb'

tester = {"id" => nil, "title" => 'The shining', "author_id"=> nil, "author" => 'Stephen King', "checked_out" => nil}

get('/') do
  Book.new(tester).save()
  @books = Book.all()
  erb(:home)
end