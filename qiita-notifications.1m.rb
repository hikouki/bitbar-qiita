#!/usr/local/bin/ruby
# coding: utf-8

# <bitbar.title>Qiita Notifications</bitbar.title>
# <bitbar.version>v1.0.0</bitbar.version>
# <bitbar.author>hikouki</bitbar.author>
# <bitbar.author.github>hikouki</bitbar.author.github>
# <bitbar.desc>Qiita Notifications</bitbar.desc>
# <bitbar.image>https://raw.githubusercontent.com/hikouki/bitbar-redmine/master/preview.png</bitbar.image>
# <bitbar.dependencies>ruby</bitbar.dependencies>
# <bitbar.abouturl>https://github.com/hikouki</bitbar.abouturl>

require 'net/http'
require 'uri'
require 'json'

# a6140cbf6e84a0bAffb0cX49138fc5687310b518
#   or
# launchctl setenv QIITA_ACCESS_TOKEN a6140cbf6e84a0bAffb0cX49138fc5687310b518
TOKEN = ENV["QIITA_ACCESS_TOKEN"] || ''

unread_count_api = URI.parse("http://qiita.com/api/notifications/count")
notification_api = URI.parse("http://qiita.com/api/notifications")

begin
  res = Net::HTTP.start(unread_count_api.host, unread_count_api.port, use_ssl: unread_count_api.scheme == 'https') do | http |
    http.get(unread_count_api.request_uri, { 'Authorization' => "Bearer #{TOKEN}" })
  end

  raise "error #{res.code} #{res.message}" if res.code != '200'

  unread_count_api_body = JSON.parse(res.body, symbolize_names: true)

  notification_count = unread_count_api_body[:count] > 10 ? 10 : unread_count_api_body[:count]

  puts notification_count.zero? ? "● | color=#7d7d7d" : "● | color=#59bb0c"
  puts "---"
  puts "Qiita | href=http://qiita.com"
  puts "---"

  if notification_count.zero?
    puts "No new notifications. | color=#7d7d7d href=http://qiita.com size=12"
  else
    res = Net::HTTP.start(notification_api.host, notification_api.port, use_ssl: notification_api.scheme == 'https') do | http |
      http.get(notification_api.request_uri, { 'Authorization' => "Bearer #{TOKEN}" })
    end

    notification_body = JSON.parse(res.body, symbolize_names: true)

    notification_count.times do | v |
      notification = notification_body[v]
      action = notification[:action]
      user = notification[:users].first[:url_name]
      title = notification[:short_title]
      puts "● #{user} が #{title} を #{action} しました。| color=black href=http://qiita.com size=12"
    end

  end

  puts "---"
  puts "Refresh | color=#7d7d7d refresh=true"

rescue => e
  puts "● ! | color=#ECB935"
  puts "---"
  puts "Exception: #{$!}"
  puts e.backtrace
end
