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

    def all
      Enumerator.new do |yielder|
        logger = Config.get(:logger)
        file_count = @enumarks.count

        @enumarks.each_with_index do |enum, idx|
          enum.each do |item|
            yielder << item
            logger.printf("--> %6d/%-6d = %3f \r", idx + 1, file_count, ((idx + 1).to_f / file_count * 100).round(2)) if logger
          end
        end

        logger.puts if logger
      end
    end
  end
end
