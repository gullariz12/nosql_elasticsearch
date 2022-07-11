class Listing
  include Mongoid::Document

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  field :beds, type: Integer
  field :baths, type: Integer

  def as_indexed_json
    as_json(except: [:id, :_id])
  end
end
