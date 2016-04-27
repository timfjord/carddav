class Carddav::Card
  attr_reader :raw, :parsed

  def self.normalize(data)
    data.to_s.gsub '&#13', ''
  end

  def initialize(data)
    @raw = data.to_s
    @parsed = VCardigan.parse self.class.normalize(data)
  end

  def name
    vcard_field :fn
  end

  def email
    vcard_field :email
  end

  def image
    vcard_field :photo
  end

  private

  def vcard_field(name)
    field = parsed.send name.to_s
    field && field.first && field.first.values.join
  end
end
