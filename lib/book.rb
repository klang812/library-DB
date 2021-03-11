require_relative 'utils'

class Book
  include Utils

  attr_accessor :checked_out, :id, :author, :author_id, :checked_out
  initialize(attr)
    @title = attr["title"]
    @id = attr["id"]
    @author = attr["author"]
    @author_id = attr["author_id"]
    @checked_out = attr["checked_out"] && set_bool( attr["checked_out"] )
  end

  def set_bool(bool)
    bool == "f" ? false : true
  end

  def self.all
    all_books = DB.exec("SELECT * FROM books ORDER BY title")
    books = []
    all_books.each do |book|
      id = book["id"].to_i
      title = book["title"]
      author = DB.exec("Select author FROM authors WHERE id = #{ book.author_id }")
      author_id = book["author_id"].to_i
      checked_out = book["checked_out"]
      books.push(Book.new({id: id, title: title, author: author, author_id: author_id, checked_out: checked_out}))
    end
    books
  end

  def save
    @author_id = DB.exec(
      "SELECT id FROM authors WHERE lower(author) = ('#{ @author_id.downcase }');"
    ).grab_id()

    if !@author_id
      @author_id = DB.exec("INSERT INTO authors (author) VALUES ('#{ @author }') RETURNING id;").grab_id()
    end

    @return_values = DB.exec("INSERT INTO books (title, author_id) VALUES ('#{ @title }', '#{ @author_id }') RETURNING id, checked_out;").first()

    @id = @return_values["id"]
    @checked_out = set_bool(@return_values["checked_out"])
  end

  def grab_id
    self.first['id'].to_i()
  end

  def status
    status = !@checked_out
    DB.exec("UPDATE books SET checked_out = #{status} WHERE id = #{@id};")
  end

  def self.find_book( book_id )
    book = DB.exec("SELECT * FROM books WHERE id = #{ book_id };").first()
    author = DB.exec("Select author FROM authors WHERE id = #{ book.author_id }").first()
    book["author"] = author["author"]
    Book.new(book)
  end

  def update(attributes)
    if (attributes.has_key?(:title)) && (attributes.fetch(:title) != nil)
      @title = attributes.fetch(:title)
      DB.exec("UPDATE books SET title = '#{@title}' WHERE id = #{@id};")
    end
    if (attributes.has_key?(:author)) && (attributes.fetch(:author) != nil)
      @author = attributes.fetch(:author)
      DB.exec("UPDATE authors SET author = '#{@author}' WHERE id = #{@author_id};")
    end
  end

  def self.delete ( book_id )
    DB.exec("DELETE FROM books WHERE id = #{ book_id };")
  end

end

