# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'rack/protection'
require 'securerandom'

use Rack::Protection
set :erb, escape_html: true

Dir.mkdir('resources') unless Dir.exist?('resources')

get '/memos' do
  file_names = Dir.glob('resources/*.json').sort_by { |f| File.birthtime(f) }
  @articles = file_names.map do |filepath|
    id = File.basename(filepath, '.json')
    article_content = File.read(filepath)
    article = JSON.parse(article_content)
    title = article['title']
    content = article['content']
    { id: id, title: title, content: content }
  end

  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  filename = "resources/#{SecureRandom.hex(16)}.json"
  filename = "resources/#{SecureRandom.hex(16)}.json" while File.exist?(filename)

  data_content = {
    title: params[:new_title],
    content: params[:new_content]
  }
  File.write(filename, JSON.generate(data_content))

  redirect '/memos'
end

get '/memos/:id' do
  @id = params['id']
  file_path = "resources/#{@id}.json"
  article_content = File.read(file_path)
  @article = JSON.parse(article_content)

  erb :show
end

get '/memos/:id/edit' do
  @id = params['id']
  file_path = "resources/#{@id}.json"
  article_content = File.read(file_path)
  @article = JSON.parse(article_content)

  erb :edit
end

patch '/memos/:id' do
  filename = "resources/#{params['id']}.json"
  data_content = {
    title: params[:edit_title],
    content: params[:edit_content]
  }
  File.write(filename, JSON.generate(data_content))

  redirect "/memos/#{params['id']}"
end

delete '/memos/:id' do
  filename = "resources/#{params['id']}.json"
  File.delete(filename)

  redirect '/memos'
end
