class Listing
  include Mongoid::Document

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  field :beds, type: Integer
  field :baths, type: Integer

  index_name 'sample_task'
  document_type self.name.downcase

  settings index: { number_of_shards: 1 } do
    mappings dynamic: false do
      indexes :beds, type: :integer
      indexes :baths, type: :integer
    end
  end

  def self.search(query)
    __elasticsearch__.search(
      {
        query:
        {
          range: {
            beds: {
              gte: query[:beds_min],
              lte: query[:beds_max],
              boost: 2.0
            }
          },
          range: {
            baths: {
              gte: query[:baths_min],
              lte: query[:baths_max],
              boost: 2.0
            }
          }
        }
      }
    )
  end

  def as_indexed_json(options = nil)
    self.as_json( only: [ :beds, :baths ] )
  end
end
