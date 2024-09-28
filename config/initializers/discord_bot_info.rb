require 'discordrb'

Thread.new do
  bot = Discordrb::Bot.new token: Rails.application.credentials[:discord_bot_token], intents: [:messages, :guilds]
  puts bot.inspect

  bot.message(with_text: 'Ping!') do |event|
    event.respond 'Pong!'
  end

  puts "before bot run"
  bot.run
end

puts "Discord bot initialized in a separate thread."
