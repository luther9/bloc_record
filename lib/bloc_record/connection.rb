# Class methods
module Connection
  def connection
    @connection ||= BlocRecord.database_type.new(BlocRecord.database_filename)
  end
end
