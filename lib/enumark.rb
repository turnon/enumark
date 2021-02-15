# frozen_string_literal: true

require_relative "enumark/version"
require 'enumark/item'
require 'enumark/category'

class Enumark
  include Enumerable

  class Grouping
    Group = Struct.new(:name, :items)

    def initialize(enumark, key, &post)
      @lock = Mutex.new
      @collection = nil

      @enumark = enumark
      @key = key
      @post = post
    end

    def each(&block)
      unless @collection
        @lock.synchronize do
          @collection = @enumark.group_by(&@key)
          @collection = @post.call(@collection) if @post
          @collection = @collection.map{ |k, items| Group.new(k, items) }
        end
      end

      @collection.each(&block)
    end
  end

  def initialize(file, items: nil)
    @file = file
    @lock = Mutex.new
    @items = items

    @hosts = Grouping.new(self, :host)
    @dup_titles = Grouping.new(self, :name){ |groups| groups.select{ |_, items| items.count > 1 } }
    @dup_hrefs = Grouping.new(self, :href){ |groups| groups.select{ |_, items| items.count > 1 } }
    @cates = Grouping.new(self, :categories_str)
  end

  def each(&block)
    read_all_lines
    @items.each(&block)
  end

  def each_host(&block)
    @hosts.each(&block)
  end

  def each_dup_title(&block)
    @dup_titles.each(&block)
  end

  def each_dup_href(&block)
    @dup_hrefs.each(&block)
  end

  def each_category(&block)
    @cates.each(&block)
  end

  [:+ ,:-, :&, :|].each do |op|
    class_eval <<-EOM
      def #{op}(another)
        new_items = self.to_a #{op} another.to_a
        Enumark.new(nil, items: new_items)
      end
    EOM
  end

  private

  def read_all_lines
    return if @items

    @lock.synchronize do
      _read_all_lines unless @items
    end
  end

  def _read_all_lines
    categories = []
    @items = []

    File.new(@file).each do |line|
      case line
      when Item::PREFIX
        item = Item.new(line, categories.dup)
        @items.push(item)
      when Category::START
        categories.push(Category.new(line))
      when Category::ENDIND
        categories.pop
      end
    end
  end
end
