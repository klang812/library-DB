require_relative 'utils'

class Patron
  include Utils
  initialze(attr)
    @id = attr['id']
    @name = attr['name']
  end

  def save()
    @id = DB.exec("INSERT INTO patrons (name) VALUES ('#{@name}') RETURNING id;").grab_id
  end

  def checkout_book( book_id )
    @book = Book.find_book( book_id )
    @book.status()
    DB.exec("INSERT INTO checkouts (book_id, patron_id) VALUES (#{ book_id }, #{@id});")
  end

  def return_book( book_id )
    @book = Book.find_book( book_id )
    @book.status()
    DB.exec("UPDATE checkouts SET currently_out = FALSE WHERE book_id = #{ book_id } AND currently_out = TRUE;")
  end
end
