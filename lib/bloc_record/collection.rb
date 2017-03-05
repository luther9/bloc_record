module BlocRecord
  class Collection < Array
    #5
    def update_all updates
      ids = self.map(&:id)
      #6
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def take num=1, rng=nil
      self.class.new(sample(num, random: rng))
    end
  end
end
