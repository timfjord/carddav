class Carddav::Url
  def initialize(uri)
    @uri = URI uri
  end

  def new(path)
    return self.class.new path if /^https?:\/\// =~ path
    uri = @uri.dup
    uri.path = path.start_with?('/') ? path : "/#{path}"
    self.class.new uri
  end

  def to_s
    @uri.to_s
  end
end
