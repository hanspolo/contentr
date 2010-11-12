module MmCms

  ##
  # TBD
  #
  class Item
    # Includes
    include Mongoid::Document
    include Mongoid::Tree

    # Fields & Relations
    field :name
    field :slug, :index => true
    field :path, :index => true
    #references_many :children, :class_name => 'MmCms::Item', :foreign_key => :parent_id, :inverse_of => :parent
    #referenced_in :parent, :class_name => 'MmCms::Item', :inverse_of => :children, :index => true
    embeds_many :data, :class_name => 'MmCms::Data::Item' do
      def get(name)
        @target.select { |data| data.name == name }.first
      end
    end

    # Validations
    validates_presence_of   :name
    validates_presence_of   :slug
    validates_uniqueness_of :slug

    # Protect attributes from mass assignment
    attr_accessible :name, :parent

    # Callbacks
    before_validation :generate_slug
    before_destroy    :destroy_children
    before_validation :rebuild_path
    after_rearrange   :rebuild_path

    def self.find_by_path(path)
      MmCms::Item.where(:path => path).first
    end

    def to_liquid
      MmCms::ItemLiquidProxy.new(self)
    end

  protected

    def generate_slug
      self.slug = name.to_url
    end

    def rebuild_path
      self.path = self.ancestors_and_self.collect(&:slug).join('/')
    end
  end

  ##
  # TBD
  #
  class ItemLiquidProxy < Liquid::Drop

    def initialize(item)
      @item = item
    end

    def data
      MmCms::ItemDataLiquidProxy.new(@item.data)
    end

    def dataset
      @item.data
    end

    def name
      @item.name
    end

    def slug
      @item.slug
    end

    def path
      @item.path
    end
  end

  ##
  # TBD
  #
  class ItemDataLiquidProxy < Liquid::Drop

    def initialize(data)
      @data = data
    end

    # method missing
    def before_method(m)
      @data.each { |d| return d if d.try(:name) == m }
      nil
    end
  end
end