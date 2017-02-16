module BlocRecord
  def self.connect_to filename
    if File.exist?(filename)
      @database_filename = filename
    else
      raise "File doesn't exist"
    end
  end

  def self.database_filename
    @database_filename
  end
end
