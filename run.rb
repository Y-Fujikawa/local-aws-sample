require 'dotenv'
require 'pg'
require 'csv'
require 'aws-sdk'

Dotenv.load

# DBに接続する
begin
  # conn を使い PostgreSQL を操作する
  conn = PG::connect(:host => ENV["PG_HOST"], :dbname => ENV["PG_DBNAME"], :port => ENV["PG_PORT"])
  p '接続できました'
  result = conn.exec("SELECT * FROM #{ENV['TARGET_TABLE']}")
ensure
  # データベースへのコネクションを切断する
  conn.finish
  p '切断しました'
end

# S3に保存するために体裁を整える
filename = ENV["CSV_FILE_NAME"] + Date.today.to_s + ".csv"
CSV.open(filename, "wb") do |csv|
  result.values.each do |row|
    csv << row
  end
end

if ENV['USE_AWS'] == 'true'
  # S3に接続してCSVファイルを保存する
  s3 = AWS::S3.new(
    :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
  )
  # TODO S3上に同名のファイルが存在した場合、削除してからアップロードする？
  s3.buckets[ENV['AWS_S3_BUCKET_NAME']].objects[File.basename(filename)].write(:file => File.expand_path(filename))
end
