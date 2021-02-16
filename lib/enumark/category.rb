# frozen_string_literal: true

class Enumark
  class Category

    START = /^\s.*<DT><H3/
    ENDIND = /^\s.*<\/DL><p>/
    PATTERN = /ADD_DATE="(.*?)".*LAST_MODIFIED="(.*?)".*>(.*)<\/H3/

    attr_reader :name
    alias_method :inspect, :name
    alias_method :to_s, :name

    def initialize(line)
      m = line.match(PATTERN)
      @add_date = m[1]
      @last_mod = m[2]
      @name = m[3]
    end
  end
end
