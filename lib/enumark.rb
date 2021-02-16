# frozen_string_literal: true

require_relative "enumark/version"
require 'enumark/item'
require 'enumark/category'
require 'enumark/grouping'

class Enumark
  include Enumerable

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
    sort_by_add_date!
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

  def sort_by_add_date!
    return if @sorted

    @lock.synchronize do
      next if @sorted

      @items.sort!{ |i1, i2| i2.add_date <=> i1.add_date }
      @sorted = true
    end
  end
end
