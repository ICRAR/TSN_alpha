require 'json'
require 'csv'

path = '/media/abeckley/UUI'
dir = path + "/Data/*"
output_filename = "./app/views/misc/sf_demo_data.json"
file_names = Dir[dir]
data_points = []

file_names.each do |file_name|
  f = File.read file_name
  csv =  CSV.parse f, headers: true
  csv.each do |row|
    unless row["ParameterNumber"] == "ParameterNumber"
      data_points.push row.to_hash
    end
  end
end

data_out = {points: data_points}

File.write output_filename, data_out.to_json
