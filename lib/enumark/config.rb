# frozen_string_literal: true

class Enumark
  module Config
    class << self
      def set(**cfg)
        (@cfg ||= {}).merge!(cfg)
      end

      def get(key)
        @cfg[key]
      end
    end

    set
  end
end
