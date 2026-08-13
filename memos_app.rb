# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'rack/protection'
require 'securerandom'

DATA_AREA = 'resources'

configure do
  use Rack::Protection
  set :erb, escape_html: true
end

Dir.mkdir(DATA_AREA) unless Dir.exist?(DATA_AREA)

def load_articles(file_id = nil)
  file_names = Dir.glob(File.join(DATA_AREA, '*.json')).sort_by { |f| File.birthtime(f) }
  articles = file_names.map do |file_name|
    id = File.basename(file_name, '.json')
    article_json = JSON.load_file(file_name)
    { id:, title: article_json['title'], content: article_json['content'] }
  end

  return articles unless file_id

  articles.find { |article| article[:id] == file_id }
end

get '/memos' do
  @articles = load_articles
  @page_title = '一覧表示'

  erb :index
end

get '/memos/new' do
  @page_title = '新規作成'

  erb :new
end

post '/memos' do
  file_name = "#{File.join(DATA_AREA, SecureRandom.uuid)}.json"
  data_content = {
    title: params[:new_title],
    content: params[:new_content]
  }
  File.write(file_name, JSON.generate(data_content))

  redirect '/memos'
end

get '/memos/:id' do
  @id = params['id']
  file_name = "#{File.join(DATA_AREA, @id)}.json"
  halt 404 unless File.exist?(file_name)

  @article = JSON.load_file(file_name)
  @page_title = '個別表示'

  erb :show
end

get '/memos/:id/edit' do
  @id = params['id']
  file_name = "#{File.join(DATA_AREA, @id)}.json"
  halt 404 unless File.exist?(file_name)

  @article = JSON.load_file(file_name)
  @page_title = '編集画面'

  erb :edit
end

patch '/memos/:id' do
  article = load_articles(params['id'].to_s)
  halt 404 unless article
  file_name = "#{File.join(DATA_AREA, article[:id])}.json"
  data_content = {
    title: params[:edit_title],
    content: params[:edit_content]
  }
  File.write(file_name, JSON.generate(data_content))

  redirect "/memos/#{params['id']}"
end

delete '/memos/:id' do
  article = load_articles(params['id'].to_s)
  halt 404 unless article
  file_name = "#{File.join(DATA_AREA, article[:id])}.json"

  File.delete(file_name)

  redirect '/memos'
end
