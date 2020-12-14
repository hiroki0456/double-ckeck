require 'slack'
require 'Date'
require 'Time'
require 'logger'
# slack api token
token = ENV['SLACK_API_TOKEN']
# 今日の日付
today = Date.today.strftime('%F')
# 指定したい日付
yesterday = (Date.today - 1).strftime('%F')
# 取得したい日付（from)
oldest = Time.parse(yesterday + " 22:00:00").to_i
# 取得したい日付（to)
latest = Time.parse(today + " 10:00:00").to_i

# 受講生名とタイムスタンプの取得
def get_student_and_ts(client, oldest, latest)
  # メッセージの取得
  messages = client.conversations_history(channel: 'C014KGE02SK', oldest: oldest, latest: latest, count: 1000)['messages']
  # 日付の並び替え
  new_messages = messages.sort{|a, b| a['ts'] <=> b['ts']}
  # 名前をいれる配列
  student_arr = []
  # 日付をいれる配列
  ts_arr = []
  # 重複受講生の確認
  double_student_arr = []
  # 受講生とタイムスタンプを取得
  new_messages.each do |msg|
    begin
      # 受講生名の取得
      student_name = msg['attachments'][0]['fields'][0]['value']
      # タイムスタンプの取得
      ts = msg['ts']
      # 受講生が被っていたら日付と受講生名を配列にいれる
      if student_arr.include?(student_name)
        ts_arr << ts
        double_student_arr << student_name
        # 被ってなかったら受講生を配列にいれる
      else
        student_arr << student_name
      end
    rescue => exception
      logger = Logger.new("/dev/null")
      logger.error(exception)
    end
  end
  # メソッドの呼び出し
  stamp_add(client, ts_arr)
end

  # 日付のメッセージにスタンプを押す
def stamp_add(client, ts_arr)
  ts_arr.each do |ts|
    client.reactions_add(channel: 'C014KGE02SK', name: "chouhuku", timestamp: ts)
  end
end

# インスタンスの生成
client = Slack::Client.new(token: token)
# メソッドの呼び出し
get_student_and_ts(client, oldest, latest)
