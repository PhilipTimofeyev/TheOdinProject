require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_number(number)
  number = number.gsub(/\D/, "")
  if number.size == 11 && number[0] == '1'
    number[1..-1]
  elsif number.size == 10
    number
  else
    "Bad Number"
  end
end

def date_parse(date)
  formatted_date = Time.strptime(date, "%m/%d/%Y %H:%M") {|year| year + (year < 70 ? 2000 : 1900)}
  # p formatted_date.hour
  # time = formatted_date.strftime("%d/%m/%Y %H:%M")
  # p formatted_date.strftime("%d")
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'



contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

peak_reg_hour_hsh = Hash.new(0)
peak_reg_day_hsh = Hash.new(0)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  date = date_parse(row[:regdate])

  peak_reg_hour_hsh[date.hour.to_s + ":00"] += 1
  peak_reg_day_hsh[date.strftime("%A")] += 1
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end

peak_hours = peak_reg_hour_hsh.sort_by {|hour, count| count}.reverse.to_h.keys
peak_days = peak_reg_day_hsh.sort_by {|day, count| count}.reverse.to_h.keys

puts "Highest registration hours are #{peak_hours[0..1].join(", ")} and #{peak_hours[2]}."
puts "Highest registration days are #{peak_days[0..1].join(", ")} and #{peak_days[2]}."