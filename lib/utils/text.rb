require 'text'

module Utils
  module Text
    def Text.get_best_rate collection, text, method = 'name'
      best_rate = 0
      best_element = nil
      collection.each do |element|
        rate = ::Text::WhiteSimilarity.new.similarity(text, element.send(method))
        if rate > best_rate
          best_rate = rate
          best_element = element
        end
      end
      best_element
    end
  end
end
