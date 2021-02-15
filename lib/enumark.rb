# frozen_string_literal: true

require_relative "enumark/version"

class Enumark
  include Enumerable

  CATEGORY_START = /^\s.*<DT><H3/
  CATEGORY_END = /^\s.*<\/DL><p>/
  CATEGORY_NAME = /ADD_DATE="(.*?)".*LAST_MODIFIED="(.*?)".*>(.*)<\/H3/

  ITEM_PREFIX = /^\s.*<DT><A/
  ITEM_NAME = /HREF="(.*?)".*ADD_DATE="(.*?)".*>(.*)<\/A>/

  class Category
    attr_reader :name
    alias_method :inspect, :name
    alias_method :to_s, :name

    def initialize(line)
      m = line.match(CATEGORY_NAME)
      @add_date = m[1]
      @last_mod = m[2]
      @name = m[3]
    end
  end

  class Item
    attr_reader :name, :href, :categories

    USELESS_SHARP = /\#.*$/

    def initialize(line, categories)
      m = line.match(ITEM_NAME)
      @href = m[1].gsub(USELESS_SHARP, '')
      @add_date = m[2]
      @name = m[3]
      @categories = categories
    end

    def inspect
      @inspect ||= "#{categories_str}> #{name}"
    end

    def categories_str
      @categories_str ||= "/#{categories.join('/')}"
    end

    def to_s
      inspect
    end

    def host
      @host ||= (URI.parse(href).host rescue 'unknown')
    end
  end

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

  def initialize(file)
    @file = file
    @lock = Mutex.new
    @items = nil

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
      when ITEM_PREFIX
        item = Item.new(line, categories.dup)
        @items.push(item)
      when CATEGORY_START
        categories.push(Category.new(line))
      when CATEGORY_END
        categories.pop
      end
    end
  end
end
