require 'sinatra'
require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'
require './lib/book'
require './databases/db'
also_reload 'lib/**/*.rb'

# tester = {"id" => nil, "title" => 'The shining', "author_id"=> nil, "author" => 'Stephen King', "checked_out" => nil}

# tester2 = {"id" => nil, "title" => 'Dogs Best Day', "author_id"=> nil, "author" => 'Stanford Bigsly', "checked_out" => nil}

get('/') do
  @books = Book.all()
  erb(:home)
end


get('/books') do
  @books = Book.all()
  erb(:books)
end


get('/books/:id') do
  @book = Book.find_book(params[:id])
  erb(:book)
end

post('/books') do
  title = params[:title]
  author = params[:author]
  Book.new({"title" =>  title, "author" => author}).save
  redirect to('/books')
end


delete('/books/:id') do
  Book.delete(params[:id])
  redirect to('/books')
end


patch('/books/:id') do
  @book = Book.find_book(params[:id])
  @book.update(params)
  redirect to('/books')
end

get('/authors') do
  @authors = Book.find_authors
  erb(:authors)
end

get('/authors/:id') do
  @author = Book.books_by_author(params[:id])
  erb(:author)
end





