module BlocRecord
  class Collection < Array
    #5
    def update_all updates
      ids = self.map(&:id)
      #6
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def take num=1, rng=nil
      new(sample(num, random: rng))
    end

    def where pairs
      new(select { |item|
            result = true
            pairs.each_pair { |key, value|
              if item.send(key) != value
                result = false
              end
            }
            result
          })
    end
  end
end
