# Seeds a coherent dev dataset for the forum: users, factions, and a full
# category -> forum -> thread -> reply tree. Safe to re-run; it wipes and
# rebuilds the forum data (and users) each time.
#
# Note: forum_threads/thread_replies have no body/content column yet, so
# seeded posts are titles + flags only, no post text.

USER_COUNT = 40
UNCONFIRMED_USER_COUNT = 3

FACTIONS = {
  "Progressive Alliance" => "#6b4fa0",
  "Liberty Caucus" => "#a0524f",
  "Centrist Coalition" => "#4f8aa0",
  "Populist Front" => "#7a9a4f",
  "Independent Bloc" => "#a0824f"
}.freeze

FORUM_STRUCTURE = {
  "Announcements & News" => [
    { title: "Site Announcements", description: "Official updates and news from the staff.", threads: 8..15, replies: 0..10 }
  ],
  "General Discussion" => [
    { title: "Politics & Current Events", description: "Debate the issues of the day. Keep it civil, or the mods will keep it for you.", threads: 25..45, replies: 5..60 },
    { title: "Off-Topic Lounge", description: "Anything goes (within reason). Movies, sports, memes, life.", threads: 15..30, replies: 0..40 }
  ],
  "Community" => [
    { title: "Introductions & Feedback", description: "New here? Say hello. Got a suggestion for the site? Tell us.", threads: 15..25, replies: 0..10 },
    { title: "Site Support", description: "Technical issues, bug reports, and how-do-I-do-that questions.", threads: 10..20, replies: 0..15 }
  ]
}.freeze

ActiveRecord::Base.transaction do
  puts "Clearing existing data..."
  ActiveRecord::Base.connection.execute("DELETE FROM users_roles")
  ThreadReply.delete_all
  ForumThread.delete_all
  Forum.delete_all
  ForumCategory.delete_all
  User.delete_all
  Faction.delete_all
  Role.delete_all

  puts "Creating admin user (admin@quorum.test / password123)..."
  admin = User.create!(
    email: "admin@quorum.test",
    password: "password123",
    password_confirmation: "password123",
    confirmed_at: Time.current
  )
  admin.add_role(:admin)

  puts "Creating #{USER_COUNT} users..."
  users = USER_COUNT.times.map do
    User.create!(
      email: Faker::Internet.unique.email,
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end

  puts "Creating #{UNCONFIRMED_USER_COUNT} unconfirmed users (pending registrations)..."
  UNCONFIRMED_USER_COUNT.times do
    User.create!(
      email: Faker::Internet.unique.email,
      password: "password123",
      password_confirmation: "password123"
    )
  end

  puts "Creating #{FACTIONS.size} factions..."
  factions = FACTIONS.map do |name, color|
    Faction.create!(
      name: name,
      description: Faker::Lorem.sentence(word_count: 12),
      color: color,
      is_active: true
    )
  end

  puts "Assigning some users to factions..."
  users.each do |user|
    next if rand < 0.35 # leave some users unaffiliated

    user.update!(faction: factions.sample)
  end

  puts "Creating forum structure..."
  FORUM_STRUCTURE.each_with_index do |(category_title, forums), category_index|
    category = ForumCategory.create!(
      title: category_title,
      description: Faker::Lorem.sentence(word_count: 10),
      index_order: category_index,
      is_visible: true,
      affiliation_factor: 1.0
    )

    forums.each_with_index do |forum_data, forum_index|
      forum = Forum.create!(
        forum_category: category,
        title: forum_data[:title],
        description: forum_data[:description],
        index_order: forum_index,
        is_visible: true,
        affiliation_factor: 1.0
      )

      rand(forum_data[:threads]).times do
        thread = ForumThread.create!(
          forum: forum,
          user: users.sample,
          title: Faker::Lorem.sentence(word_count: rand(4..10)).chomp("."),
          body: Faker::Lorem.paragraphs(number: rand(1..3)).join("\n\n"),
          is_draft: false,
          is_sticky: rand < 0.05,
          is_visible: true,
          can_be_replied_to: true,
          includes_poll: rand < 0.1,
          views_count: rand(0..500),
          created_at: Faker::Time.backward(days: 180)
        )

        reply_time_span = (Time.current - thread.created_at).to_i
        rand(forum_data[:replies]).times do
          ThreadReply.create!(
            forum_thread: thread,
            user: users.sample,
            body: Faker::Lorem.paragraph(sentence_count: rand(1..4)),
            can_be_quoted: true,
            created_at: thread.created_at + rand(0..reply_time_span)
          )
        end
      end
    end
  end
end

puts "Done: #{User.count} users, #{Faction.count} factions, #{ForumCategory.count} categories, " \
     "#{Forum.count} forums, #{ForumThread.count} threads, #{ThreadReply.count} replies."

load Rails.root.join("db/seeds/fallacies.rb")
