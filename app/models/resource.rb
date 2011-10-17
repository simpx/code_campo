class Resource
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::NumberId
  include Mongo::Voteable

  voteable self, :up => 1, :index => true

  field :title
  field :url
  field :tags, :type => Array

  belongs_to :user

  attr_accessible :title, :url, :tag_string

  validates :title, :url, :presence => true
  validates :tag_string, :tag_string => true, :format => { :with => /\A[^\/]+\z/, :message => "no allow slash", :allow_blank => true}
  validates :url, :format => {:with => URI::Parser.new.regexp[:ABS_URI]}

  def tag_string=(string)
    self.tags = string.to_s.downcase.split(/[,\s]+/).uniq
  end

  def tag_string
    self.tags.to_a.join(', ')
  end

  def host
    URI.parse(url).try(:host)
  end

  def relate_resources(count)
    Resource.any_in(:tags => tags.to_a).limit(count).where(:_id.ne => id)
  end
end