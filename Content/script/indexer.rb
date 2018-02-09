#!/usr/bin/ruby
require 'rubygems'
require 'nokogiri'

concept_file_name = ARGV[0]

if (!concept_file_name)
  puts "Usage: indexer.rb <CONCEPT_FILE>"
  exit
end

doc = nil

File.open(concept_file_name, "r") do |concept_file|
  doc = Nokogiri::HTML(concept_file)
  index = -1;
  p = doc.css("p")
  p.each do |paragraph_element|
    words = paragraph_element.content.split
    wrapped = words.collect do |word|
      %Q{<span class="highlight-target" index="#{index += 1}">#{word}</span><span class="highlight-target" index="#{index += 1}"> </span>}

    end
    paragraph_element.inner_html = wrapped.join
    if (index > 300)
      paragraph_element.inner_html += "<b>300</b>"
      break
    end
  end
end

puts doc.to_html
