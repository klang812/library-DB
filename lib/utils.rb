module Utils
  def grab_id
    self.first['id'].to_i()
  end
end