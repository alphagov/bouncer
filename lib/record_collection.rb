class RecordCollection < Struct.new(:records)
  def <<(record)
    records << record
  end

  def size
    records.size
  end

  def include?(record)
    records.include?(record)
  end

  def find_by(params)
    records.detect { |record| params.all? { |key, value| record.send(key) == value } }
  end
end
