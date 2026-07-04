# memos-app
フィヨルドブートキャンプの課題用リポジトリです。
sinatraを利用した簡易メモアプリ。DBは使用していません。

## 概要（Overview）
メモ（タイトル/内容）を作成するだけのアプリケーションです。
機能は、作成／表示／編集／削除の４つのみ。

## 必須プログラム（Prerequisites）
プログラム
- Ruby

Gem
- Sinatra
- rackup
- webrick

## インストール手順(Installation)
1. リポジトリをダウンロード（クローン）します。
   ```bash
   git clone https://github.com/Shizunari/memos-app
   ```
2. プロジェクトのフォルダに移動します。
   ```bash
   cd リポジトリ名
   ```
3. 必要なライブラリをインストールします。
   ```bash
   bundle install
   ```
4. データベースの準備をします。
   ```bash
   bundle exec ruby memos_app.rb -p 4567
   ```
   Localhost以外で使用する場合には、引数で接続範囲を指定（-h 0.0.0.0）
5. http://localhost:4567/memos にアクセス

## 使い方（Usage）
1. プロジェクトのフォルダで次のコマンドを使用しWEBサーバを起動します
   ```bash
   bundle exec ruby memos_app.rb -p 4567
   ```
   Localhost以外で使用する場合には、引数で接続範囲を指定（-h 0.0.0.0）

2. http://localhost:4567/memos にアクセスして使用します

