require 'pdf-reader'

def get_info(pdf_file_path)
    content = ""
    result = {}
    reader = PDF::Reader.new(pdf_file_path)
    reader.pages.each do |page|      
      content = content + page.text
      break
    end

    File.write("content.txt", content)
    who = content.scan(/1\. (.*)shall/i)[0]
    unless who.empty?
        name = who[0].scan(/Petitioner (.*)/i)[0]
        result[:Petitioner] = name[0].strip unless name.empty?
    end
    
    amount = content.scan(/(\$[\d|,|\.]+)/i)[0]
    result[:amoount] = amount[0] unless amount.empty?
    date = content.scan(/Date of Notice:(.*)/i)[0]
    # date = content.scan(/Date of Order:(.*)/i)[0] if date.empty?
    # date = content.scan(/Date of Judgment:(.*)/i)[0] if date.empty?

    result[:date] = date[0] unless date.empty?
    repondent = content.scan(/Repondent/i)[0]
    state = content.scan(/shall pay to the (.*)\$1/)[0]
    
    unless repondent && repondent.empty?
        result[:repondent] = state[0].strip unless state.empty?
    end
    result
end
puts get_info('S18173_2021-12-08_N1.pdf')

