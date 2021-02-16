# frozen_string_literal: true

class Enumark

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
end
