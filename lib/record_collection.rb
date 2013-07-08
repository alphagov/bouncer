class RecordCollection < Struct.new(:records)
  def <<(record)
    records << record
  end

  def find_by(params)
    records.detect { |record| params.all? { |key, value| record[key] == value } }
  end
end
