# frozen_string_literal: true

class Enumark
  class Item

    PREFIX = /^\s.*<DT><A/
    PATTERN = /HREF="(.*?)".*ADD_DATE="(.*?)".*>(.*)<\/A>/
    USELESS_SHARP = /\#.*$/

    attr_reader :name, :href, :add_date, :categories

    def initialize(line, categories)
      m = line.match(PATTERN)
      @href = m[1].gsub(USELESS_SHARP, '')
      @add_date = Time.at(m[2].to_i)
      @name = m[3]
      @categories = categories
    end

    def inspect
      @inspect ||= "#{add_date.strftime('%F %T')} #{categories_str}> #{name}"
    end

    def categories_str
      @categories_str ||= "/#{categories.join('/')}"
    end

    def to_s
      inspect
    end

    def hash
      href.hash
    end

    def eql?(another)
      href.eql?(another.href)
    end

    def host
      @host ||= (URI.parse(href).host rescue 'unknown')
    end
  end
end
