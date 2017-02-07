#!/usr/bin/env ruby

require 'yaml'

#This File Creates the text for markov chains to anaylyze, by using all expansions present in data/dah-cards. The output will be placed in data/dah-cards/markov.txt


all_answers = Array.new

Dir.glob(File.expand_path File.dirname(__FILE__) + "/dah-cards/*.yaml") do |yml_file|
  temparr = YAML.load_file(yml_file)
  temparr["answers"].each do |answer|
    all_answers << answer
  end
  temparr.clear
end

File.open("#{File.expand_path File.dirname(__FILE__) + '/dah-cards/markov.txt'}", "w+") do |f|
  f.puts(all_answers)
end
	
