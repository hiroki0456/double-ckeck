# APIのtoken
require 'slack'
require 'Date'
require 'TIme'
require 'logger'
token = "xoxp-81666833746-897270273667-1508531704720-404017878d6ac0242734c86a12ed3f11"
history_url = "https://slack.com/api/conversations.history"

# messageの取得
def get_message(client)
  # メッセージの取得
  messages = client.conversations_history(channel: 'C01EKCY440J', count: 1000)['messages']
  messages.each do |msg|
    begin
      puts msg["text"]
      ts = msg["ts"]
      client.reactions_add(channel: 'C01EKCY440J', name: "chouhuku", timestamp: ts)
    rescue => exception
      logger = Logger.new("/dev/null")
      logger.error(exception)
    end
  end
end

# インスタンスの生成
client = Slack::Client.new(token: token)
get_message(client)