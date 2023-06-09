require "puma"
require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    id = 0
    text.split("\n\n").map { |section| "<p id=#{id+=1}>" + section + '</p>' }.join
  end

  def highlight_keyword(paragraph, keyword)
    paragraph.gsub(/#{keyword}/, "<strong>#{keyword}</strong>")
  end
end

not_found do 
  redirect '/'
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  redirect '/' unless (1..@contents.size).include?(number)
  chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"

  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end


def matching_paragraphs(chapter, search_keyword)
  paragraphs = {}
  chapter.split("\n\n").each_with_index do |section, id|
    paragraphs[id+1] = section if section =~ /#{search_keyword}/
  end
  paragraphs
end

def matching_chapters(search_keyword)
  headlines_with_paragraphs = {}
  @contents.each_with_index do |headline, index|
    paragraphs = matching_paragraphs(File.read("data/chp#{index+1}.txt"), search_keyword)
    headlines_with_paragraphs[headline] = [index+1, paragraphs] unless paragraphs.empty?
  end
  headlines_with_paragraphs
end

get "/search" do 
  search_keyword = params['query']
  redirect "/search" if search_keyword == ''
  @chapters_matching = matching_chapters(search_keyword)
  
  erb :search
end
