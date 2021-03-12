require_relative 'utils'

class Book

  attr_accessor :title, :checked_out, :id, :author, :author_id, :checked_out
  def initialize(attr)
    @title = attr["title"]
    @id = attr["id"]
    @author = attr["author"]
    @author_id = attr["author_id"]
    @checked_out = attr["checked_out"] && set_bool( attr["checked_out"] )
  end

  def grab_id
    self.first['id']
  end

  def set_bool(bool)
    bool == "f" ? false : true
  end

  def self.all
    # the objects are returned
    all_books = DB.exec("SELECT * FROM books ORDER BY title ASC;")
    books = []
    # each iterates through the object somhow "it just knows", we use the data to set the values of all availible data and return instances in an array
    all_books.each do |book|
      id = book["id"]
      title = book["title"]
      author = DB.exec("Select author FROM authors WHERE id = #{ book["author_id"] }").first["author"]
      author_id = book["author_id"]
      checked_out = book["checked_out"]
      books.push(Book.new(
          {
            "id" => id,
            "title" => title,
            "author" => author,
            "author_id" => author_id,
            "checked_out" => checked_out
          }
      ))
    end
    books
  end

  def save
    # is there authors?
    @author_id = DB.exec(
      "SELECT id FROM authors WHERE lower(author) = ('#{ @author.downcase }');"
    )

    # nope? ok moke one and give me that id
    if !@author_id.first()
      @author_id = DB.exec(
        "INSERT INTO authors (author) VALUES ('#{ @author }') RETURNING id;"
      )
    end

    # use that info to save that id in our object
    # {"id" => nil, "title" => 'Dogs Best Day', "author_id"=> nil, "author" => 'Stanford Bigsly', "checked_out" => nil}
    @return_values = DB.exec("INSERT INTO books (title, author_id) VALUES ('#{ @title }', '#{ @author_id.first["id"] }') RETURNING id, checked_out;").first()
    # use that values to give me usable data
    @id = @return_values["id"]
    @checked_out = set_bool(@return_values["checked_out"])

    # instance works how i want it.
    self
  end

  def grab_id
    self.first['id'].to_i()
  end

  def status
    status = !@checked_out
    DB.exec("UPDATE books SET checked_out = #{status} WHERE id = #{@id};")
  end

  def self.find_book( book_id )
    # generates an instance from the id
    book = DB.exec("SELECT * FROM books WHERE id = #{ book_id };").first()
    if book
      # notice how we make a second call to match the authors name in our class and now have that value
      author = DB.exec("Select author FROM authors WHERE id = #{ book["author_id"] }").first()
      book["author"] = author["author"]
      Book.new(book)
    else
      nil
    end
  end

  def update(attributes)
    if (attributes.has_key?("title")) && (attributes.fetch("title") != '')
      @title = attributes.fetch("title")
      DB.exec("UPDATE books SET title = '#{@title}' WHERE id = #{@id};")
    end
    if (attributes.has_key?("author")) && (attributes.fetch("author") != '')
      @author = attributes.fetch("author")
      DB.exec("UPDATE authors SET author = '#{@author}' WHERE id = #{@author_id};")
    end
  end

  def self.delete ( book_id )
    DB.exec("DELETE FROM books WHERE id = #{ book_id };")
  end

  def self.find_authors(author_id: nil, author: nil)
    if author_id
      DB.exec("SELECT * FROM authors WHERE id = #{author_id};")
    elsif author
      DB.exec("SELECT * FROM authors WHERE lower(author) = #{author.downcase};")
    else
      DB.exec("SELECT * FROM authors;")
    end
  end

  def self.books_by_author ( author_id )
    books = []
    results = DB.exec("SELECT * FROM books WHERE author_id = #{author_id};")
    results.each do |result|
      book = DB.exec("SELECT * FROM books WHERE id = #{id};")
      author = DB.exec("SELECT author FROM authors WHERE id = #{author_id}").first()
      result["author_id"] = author["author_id"]
      books.push(Book.new(result))
    end
    books
  end
end

