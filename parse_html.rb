module ParseHTML
  module_function

  LINKS = %r{<A HREF=".+?">(.+?)</A>}

  def extract_links(source)
    source.scan(LINKS).flatten
  end
end
