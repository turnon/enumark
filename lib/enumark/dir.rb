# frozen_string_literal: true

class Enumark
  class Dir
    def initialize(dir)
      @enumarks = ::Dir.glob(dir).map{ |f| ::Enumark.new(f) }
      raise 'Not enough to process' if @enumarks.count <= 1
    end

    def added
      @added ||= (@enumarks[-1] - @enumarks[-2])
    end

    def deleted
      @deleted ||= @enumarks[0..-2].reverse_each.reduce(&:|) - @enumarks[-1]
    end

    def uniq
      @uniq ||= @enumarks.reverse_each.reduce(&:|)
    end

    def static
      @static ||= @enumarks.reverse_each.reduce(&:&)
    end
  end
end
