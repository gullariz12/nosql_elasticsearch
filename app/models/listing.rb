class Listing
  include Mongoid::Document

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  field :beds, type: Integer
  field :baths, type: Integer
  field :price, type: Integer

  index_name 'sample_task'
  document_type self.name.downcase

  settings index: { number_of_shards: 1 } do
    mappings dynamic: false do
      indexes :beds, type: :integer
      indexes :baths, type: :integer
      indexes :price, type: :integer
    end
  end

  def self.beds_min(query)
    query[:beds_min].present? ? query[:beds_min] : Listing.min(:beds)
  end

  def self.beds_max(query)
    query[:beds_max].present? ? query[:beds_max] : Listing.max(:beds)
  end

  def self.baths_min(query)
    query[:baths_min].present? ? query[:baths_min] : Listing.min(:baths)
  end

  def self.baths_max(query)
    query[:baths_max].present? ? query[:baths_max] : Listing.max(:baths)
  end

  def self.price_min(query)
    query[:price_min].present? ? query[:price_min] : Listing.min(:price)
  end

  def self.price_max(query)
    query[:price_max].present? ? query[:price_max] : Listing.max(:price)
  end

  def self.fetch_beds(query)
    {
      range: {
        beds: {
          gte: self.beds_min(query),
          lte: self.beds_max(query),
          boost: 2.0
        }
      }
    }
  end

  def self.fetch_baths(query)
    {
      range: {
        baths: {
          gte: self.baths_min(query),
          lte: self.baths_max(query),
          boost: 2.0
        }
      }
    }
  end

  def self.fetch_price(query)
    {
      range: {
        baths: {
          gte: self.price_min(query),
          lte: self.price_max(query),
          boost: 2.0
        }
      }
    }
  end

  def self.search_query(params)
    query = {}

    query.merge!(fetch_beds(params)) if !params[:beds_min].blank? || !params[:beds_max].blank?
    query.merge!(fetch_baths(params)) if !params[:baths_min].blank? || !params[:baths_max].blank?
    query.merge!(fetch_price(params)) if !params[:price_min].blank? || !params[:price_max].blank?

    query
  end

  def self.search(query)
    __elasticsearch__.search(
      self.search_query(query).present? ? { query: self.search_query(query) } : {}
    )
  end

  def as_indexed_json(options = nil)
    self.as_json( only: [ :beds, :baths ] )
  end
end
