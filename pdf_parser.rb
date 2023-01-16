# Ruby test #2

require 'pdf-reader'
require "google_drive"

def get_info(pdf_file_path)

  content = ""
  result = {}
  reader = PDF::Reader.new(pdf_file_path)

  reader.pages.each do |page|
    content = content + page.text
    break
  end

  result[:Petitioner] = get_petitioner(content, "Petitioner")
  appellant = get_petitioner(content, "Appellant")
  result[:Appellant] = appellant unless appellant.empty?

  result[:Respondent] = get_repondent(content, "Respondent")

  appellee = get_petitioner(content, "Appellee")
  result[:Appellee] = appellee unless appellee.empty?

  amount = content.scan(/(\$[\d|,|\.]+)/i)[0]
  result[:amoount] = amount[0].gsub(/,/, "").strip unless amount.nil? or amount.empty?
  date = content.scan(/Date of Notice:(.*)/i)[0]
  date = content.scan(/Date of Order:(.*)/i)[0] if date.nil? or date.empty?
  date = content.scan(/Date of Judgment:(.*)/i)[0] if date.nil? or date.empty?

  result[:date] = date[0].strip unless date.nil? or date.empty?

  result
end

def get_petitioner(content, role)
    
  if content.scan(/#{role}/i).empty?
    return ""
  end
  lines = content.split("\n")
  for line in 1..6 do
    matches = lines[line].match(/(.*) \)/)
    break unless matches.nil?
  end
  if matches.nil?
    for line in 1..6 do
      matches = lines[line].match(/(.*)Supreme Court No./)
      break unless matches.nil?
    end
  end

  unless matches.nil? or matches[1].nil? 
    result = matches[1].strip.gsub(/,/, '')
  end
  result

end

def get_repondent(content, role)
  
  if content.scan(/#{role}/i).empty?
    return ""
  end
  lines = content.split("\n")
  line = 16

  while line > 0
    matches = lines[line].match(/#{role}/)
    break unless matches.nil?
    line = line - 1
  end

  if line >= 1
    line = line - 1
    
    while line > 1 && !(lines[line].scan(/Date of Judgment:/i).empty?)
      line = line - 1
    end

    matches = lines[line].match(/(.*)/)
    
    unless matches.nil? && line > 1
      if matches[0].scan(/Date of Judgment:/i)
        line = line - 1
      end
      matches = lines[line].match(/(.*)/)
    end
    
    unless matches.nil? or matches[1].nil? 
      unless matches[1].scan(/(.*)Appellate Rule/).empty?
        matches = matches[1].scan(/(.*)Appellate Rule/)[0]
        who = matches[0].gsub(/,/, '').gsub(' )', '').strip            
      else
        who = matches[1].gsub(/,/, '').gsub(' )', '').strip            
      end
    end
    return who
  end
  return ""
end

def process_all
  Dir["*.pdf"].each do |file_name|
    puts get_info(file_name)
  end
end

def download_from_google_drive
  puts "Downloading PDFs from google drive..."
  session = GoogleDrive::Session.from_config("config.json")
  session.files.each do |file|
    File.write(file.title, file.download_to_string)
    puts "Downloaded #{file.title}"
    break
  end
end

download_from_google_drive
process_all