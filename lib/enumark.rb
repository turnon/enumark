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
    attr_reader :name, :categories

    def initialize(line, categories)
      m = line.match(ITEM_NAME)
      @href = m[1]
      @add_date = m[2]
      @name = m[3]
      @categories = categories
    end

    def inspect
      @inspect ||= "/#{categories.join('/')}> #{name}"
    end

    def to_s
      inspect
    end
  end

  def initialize(file)
    @file = file
    @lock = Mutex.new
    @read = false
    @items = []
  end

  def each
    return self unless block_given?

    read_all_lines
    @items.each { |item| yield item }
  end

  private

  def read_all_lines
    return if @read

    @lock.synchronize do
      next if @read

      _read_all_lines
      @read = true
    end
  end

  def _read_all_lines
    categories = []

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
