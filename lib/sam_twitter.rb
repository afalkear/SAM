module SamTwitter
  def self.post(message)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['twitter-api-key']
      config.consumer_secret     = ENV['twitter-api-key-secret']
      config.access_token        = ENV['twitter-access-token']
      config.access_token_secret = ENV['twitter-access-token-secret']
    end    

    client.update(message)
  end
end