require 'discordrb'

Thread.new do
  bot = Discordrb::Bot.new token: Rails.application.credentials[:discord_bot_token]

  @server_id = 1287644682045751399
  WELCOME_CHANNEL_ID = 1289662377901555914
  FROGGY_ROLE_ID = 1289662500966633573

  rules_message = nil

  bot.ready do
    welcome_channel = bot.channel(WELCOME_CHANNEL_ID)

    if welcome_channel.history(1).empty?
      welcome_channel.send_message("React to this message to agree to the rules").then do |message|
        rules_message = message
        rules_message.react('☑️')
      end
    else
      rules_message = welcome_channel.history(1).first
    end
  end

  bot.reaction_add do |reaction_event|
    if rules_message && reaction_event.message_id == rules_message.id && reaction_event.emoji.name == '☑️'
      member = reaction_event.user.on(@server_id)
      member.add_role(FROGGY_ROLE_ID) if member
    end
  end

  bot.message(content: 'Ping!') do |event|
    m = event.respond('Pong!')
    m.edit "Pong! Time taken: #{Time.now - event.timestamp} seconds."
  end

  bot.message(content: "whoami") do |event|
    event.respond("You're #{event.user.name}!")
    event.respond(event.user.avatar_url)
  end

  bot.register_application_command(:birthdays, 'Birthday commands', server_id: @server_id) do |cmd|
    cmd.subcommand_group('birthday', 'Birthday commands') do |group|
      group.subcommand('add', 'Add a birthday') do |sub|
        sub.user('user', 'User to add')
        sub.string('date', 'Date of birthday')
      end

      group.subcommand('remove', 'Remove a birthday') do |sub|
        sub.user('user', 'User to remove')
      end

      group.subcommand('list', 'List all birthdays')
    end
  end

  bot.application_command(:birthdays).group(:birthday) do |group|
    group.subcommand(:add) do |event|
      user_id = event.options['user']
      birthday = event.options['date']
      user = bot.user(user_id)

      new_record = Birthday.new(user_id: user_id, birthday: birthday)
      if new_record.save
        event.respond(content: "Added birthday on #{new_record.birthday} for #{user.name}")
      else
        event.respond(content: "Failed to add birthday for #{user.name}")
      end
    end

    group.subcommand(:remove) do |event|
      user_id = event.options['user']
      user = bot.user(user_id)
      birthday_record = Birthday.find_by(user_id: user_id)
      
      if birthday_record&.destroy
        event.respond(content: "Removed birthday for #{user.name}")
      else
        event.respond(content: "No birthday found for #{user.name}")
      end
    end

    group.subcommand(:list) do |event|
      all_birthdays = Birthday.all
      if all_birthdays.empty?
        event.respond(content: "No birthdays found.")
      else
        birthday_list = all_birthdays.map { |b| "<@#{b.user_id}>: #{b.birthday.strftime('%B %d, %Y')}" }.join("\n")
        event.respond(content: "Here are the birthdays:\n#{birthday_list}")
      end
    end    
  end

  bot.register_application_command(:example, 'Example commands', server_id: @server_id) do |cmd|
    cmd.subcommand_group(:fun, 'Fun things!') do |group|
      group.subcommand('calculator', 'Do math!') do |sub|
        sub.integer('first', 'First number')
        sub.string('operation', 'Operation', choices: { times: '*', divided_by: '/', plus: '+', minus: '-' })
        sub.integer('second', 'Second number')
      end
    end
  end

  bot.application_command(:example).group(:fun) do |group|
    group.subcommand(:calculator) do |event|
      result = event.options['first'].send(event.options['operation'], event.options['second'])
      event.respond(content: result.to_s)
    end
  end

  bot.register_application_command(:mod, 'Moderation commands', server_id: @server_id) do |cmd|
    cmd.subcommand_group(:tools, 'Moderation tools') do |group|
      group.subcommand('kick', 'Kick a user') do |sub|
        sub.user('user', 'User to kick')
        sub.string('reason', 'Reason for kicking', required: false)
      end
  
      group.subcommand('ban', 'Ban a user') do |sub|
        sub.user('user', 'User to ban')
        sub.string('reason', 'Reason for banning', required: false)
      end
  
      group.subcommand('purge', 'Purge messages') do |sub|
        sub.integer('amount', 'Amount of messages to purge')
      end
  
      group.subcommand('warn', 'Warn a user') do |sub|
        sub.user('user', 'User to warn')
        sub.string('reason', 'Reason for warning', required: false)
      end
    end
  end

  bot.application_command(:mod).group(:tools) do |group|
    group.subcommand(:kick) do |event|
      user = event.options['user']
      reason = event.options['reason']

      server = bot.server(@server_id)
      server.kick(user, reason: reason || 'no reason')
      event.respond("Kicking #{user.name} for #{reason || 'no reason'}")
    end

    group.subcommand(:ban) do |event|
      user = event.options['user']
      reason = event.options['reason']

      server = bot.server(@server_id)
      server.ban(user, reason: reason || 'no reason')
      event.respond("Banning #{user.name} for #{reason || 'no reason'}")
    end

    group.subcommand(:purge) do |event|
      amount_to_delete = event.options['amount']
      event.channel.history(amount_to_delete).each(&:delete)
      event.respond("Purging #{amount_to_delete} messages")
    end

    group.subcommand(:warn) do |event|
      user = event.options['user']
      reason = event.options['reason']

      found_username = bot.user(user).name
      event.respond(content: "Warning #{found_username} for #{reason || 'no reason'}")
    end
  end

  bot.run
end

puts "Discord bot initialized in a separate thread."
