require 'pdf-reader'

class PdfReader
  def driver
    all_files = Dir["/home/musa/Downloads/pdf_files/*"]
    # THIS IS PATH WHERE I HAVE KEEP PDF FILES
    all_files.each do |file_path|
      hash = {}
      data_lines = read_pdf_file(file_path)
      parties_data = find_parties(data_lines)
      parties_data.each do |data|
        key, value =  find_key_value_pair(data)
        hash[key] = value
      end
      hash["date"] = find_date(data_lines)
      hash["amount"] = find_amount(data_lines)
      puts hash
    end
  end

  private

  def find_date(lines)
    lines.select {|l| l.include? 'Date of'}[0].split(':')[1].strip rescue nil
  end

  def find_amount(lines)
    line = lines.select {|l| l.include? '$'}[0]
    index = line.index('$') rescue nil
    line[index..index+10].tr('^0-9.$', '') rescue nil
  end

  def find_key_value_pair(data)
    data = data.map { |e| e.strip.split('  ')[0] }.reject { |e| e.nil? }
    check_array = ['Petitioner,', 'Petitioners,', 'Appellant,', 'Appellees.', 'Appellee.', 'Respondent.']
    index = data.find_index(data.select { |l|  check_array.any? { |i| l.include? i }}[0])
    key = data[index]
    value = find_value(data, index)
    key = clean_data(key)
    value = clean_data(value)
    [key, value]
  end

  def clean_data(data)
    (',.)'.include? data[-1]) ? data[..-2].strip : data.strip
  end

  def find_value(data, index)
    value = data[index+=-1]
    value = (value.include? 'Date of' or value.include? 'DOB') ? data[index+=-1] : value
    (data[index-1].include? 'State of') ? data[index-1] + ' ' + value : value
  end

  def read_pdf_file(path)
    reader = PDF::Reader.new(open(path))
    text = []
    text = reader.pages.map { |p| text << p.text.scan(/^.+/) }.flatten
    text
  end

  def find_parties(data_lines)
    index = data_lines.find_index(data_lines.select { |l| l.strip.start_with? 'v.'}[0])
    return [] if index.nil?
    required_data = []
    required_data << data_lines[1..index-1]
    required_data << data_lines[index+1..index+8]
    required_data
  end

end

PdfReader.new.driver
