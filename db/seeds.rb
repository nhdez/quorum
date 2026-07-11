# Seeds a coherent dev dataset for the forum: users, factions, and a full
# category -> forum -> thread -> reply tree. Safe to re-run; it wipes and
# rebuilds the forum data (and users) each time.
#
# Note: forum_threads/thread_replies have no body/content column yet, so
# seeded posts are titles + flags only, no post text.

USER_COUNT = 40

FACTION_NAMES = [
  "Progressive Alliance",
  "Liberty Caucus",
  "Centrist Coalition",
  "Populist Front",
  "Independent Bloc"
].freeze

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
  ThreadReply.delete_all
  ForumThread.delete_all
  Forum.delete_all
  ForumCategory.delete_all
  Faction.delete_all
  User.delete_all

  puts "Creating #{USER_COUNT} users..."
  USER_COUNT.times do
    User.create!(
      email: Faker::Internet.unique.email,
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end

  puts "Creating #{FACTION_NAMES.size} factions..."
  FACTION_NAMES.each do |name|
    Faction.create!(
      name: name,
      description: Faker::Lorem.sentence(word_count: 12),
      is_active: true
    )
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
          title: Faker::Lorem.sentence(word_count: rand(4..10)).chomp("."),
          is_draft: false,
          is_sticky: rand < 0.05,
          is_visible: true,
          can_be_replied_to: true,
          includes_poll: rand < 0.1,
          created_at: Faker::Time.backward(days: 180)
        )

        reply_time_span = (Time.current - thread.created_at).to_i
        rand(forum_data[:replies]).times do
          ThreadReply.create!(
            forum_thread: thread,
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
