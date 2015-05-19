class Tag

  include DataMapper::Resource

  #defines the many-to-many relationship
  has n, :links, through: Resource

  property :id, Serial
  property :text, String

end