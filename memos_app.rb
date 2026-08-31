# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'rack/protection'
require 'pg'

DATABASE_NAME = 'memos_application_db'
TABLE_NAME = 'memo_details'
UUID_FORMAT = /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/

configure do
  use Rack::Protection
  set :erb, escape_html: true
end

CONN = PG.connect(dbname: DATABASE_NAME)
CONN.exec(<<~SQL)
  CREATE TABLE IF NOT EXISTS "#{TABLE_NAME}" (
    "memo_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "title" VARCHAR(255),
    "content" VARCHAR(5000)
  )
SQL

def load_articles(file_id = nil)
  if !file_id
    CONN.exec("SELECT memo_id, title, content FROM \"#{TABLE_NAME}\" ORDER BY title DESC")
  else
    CONN.exec_params("SELECT memo_id, title, content FROM \"#{TABLE_NAME}\" WHERE memo_id = $1", [file_id])
  end
end

get '/memos' do
  @page_title = '一覧表示'
  @articles = load_articles

  erb :index
end

get '/memos/new' do
  @page_title = '新規作成'

  erb :new
end

post '/memos' do
  CONN.exec_params(
    "INSERT INTO \"#{TABLE_NAME}\" (title, content) VALUES ($1, $2)",
    [params[:new_title], params[:new_content]]
  )

  redirect '/memos'
end

get '/memos/:id' do
  @page_title = '個別表示'
  halt 404 unless params[:id].match?(UUID_FORMAT)
  articles = load_articles(params[:id].to_s)
  halt 404 if articles.ntuples.zero?
  @article = articles.first

  erb :show
end

get '/memos/:id/edit' do
  @page_title = '編集画面'
  halt 404 unless params[:id].match?(UUID_FORMAT)
  articles = load_articles(params[:id].to_s)
  halt 404 if articles.ntuples.zero?
  @article = articles.first

  erb :edit
end

patch '/memos/:id' do
  halt 404 unless params[:id].match?(UUID_FORMAT)
  articles = load_articles(params[:id].to_s)
  halt 404 if articles.ntuples.zero?

  CONN.exec_params(
    "UPDATE \"#{TABLE_NAME}\" SET title = $1, content = $2 WHERE memo_id = $3",
    [params[:edit_title], params[:edit_content], params[:id]]
  )

  redirect "/memos/#{params['id']}"
end

delete '/memos/:id' do
  halt 404 unless params[:id].match?(UUID_FORMAT)
  articles = load_articles(params[:id].to_s)
  halt 404 if articles.ntuples.zero?

  CONN.exec_params("DELETE FROM \"#{TABLE_NAME}\" WHERE memo_id = $1", [params[:id]])

  redirect '/memos'
end
