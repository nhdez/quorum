class ForumsController < ApplicationController
  GROUP_COLORS = { admin: "#c0392b", mod: "#1e8449", senior: "#2455a4", member: "#333333" }.freeze

  def index
    @announcement = "Forum-wide election-year posting guidelines are now in effect — please review the updated Rules of Conduct before posting."
    @bias_value = 38
    @posts_analyzed = "3,482"
    @bias_history = [ 44, 41, 47, 52, 49, 55, 58, 53, 46, 42, 39, 44, 48, 51 ]

    demo_forum_path = forum_path(id: "politics-current-events")
    demo_thread_path = forum_thread_path(forum_id: "politics-current-events", id: "midterm-predictions-thread")

    @categories = [
      {
        name: "Announcements & News",
        forums: [
          {
            name: "Site Announcements", desc: "Official updates and news from the staff.",
            icon_color: "#3f9142", subforums: nil, lean: nil,
            threads: "12", posts: "340",
            last_post: { thread: "Scheduled maintenance this Tuesday", user: "Admin", user_color: GROUP_COLORS[:admin], time: "Today, 08:14 AM", avatar_color: "#c0392b", initial: "A" }
          }
        ]
      },
      {
        name: "General Discussion",
        forums: [
          {
            name: "Politics & Current Events", desc: "Debate the issues of the day. Keep it civil, or the mods will keep it for you.",
            icon_color: "#a85050", subforums: "Elections 2026, International Affairs", lean: 62,
            threads: "4,821", posts: "118,332", path: demo_forum_path,
            last_post: { thread: "Re: Midterm predictions thread", user: "PoliticalJunkie88", user_color: GROUP_COLORS[:senior], time: "Today, 11:52 AM", avatar_color: "#2455a4", initial: "P", path: demo_thread_path }
          },
          {
            name: "Off-Topic Lounge", desc: "Anything goes (within reason). Movies, sports, memes, life.",
            icon_color: "#8a8f9a", subforums: nil, lean: nil,
            threads: "2,093", posts: "55,201",
            last_post: { thread: "What are you watching tonight?", user: "popcorn_kev", user_color: GROUP_COLORS[:member], time: "Today, 10:37 AM", avatar_color: "#6b7aa8", initial: "K" }
          }
        ]
      },
      {
        name: "Community",
        forums: [
          {
            name: "Introductions & Feedback", desc: "New here? Say hello. Got a suggestion for the site? Tell us.",
            icon_color: "#3f6fa0", subforums: nil, lean: nil,
            threads: "512", posts: "3,204",
            last_post: { thread: "Hi all, long-time lurker here", user: "newbie_nancy", user_color: GROUP_COLORS[:member], time: "Yesterday, 09:02 PM", avatar_color: "#7d97c2", initial: "N" }
          },
          {
            name: "Site Support", desc: "Technical issues, bug reports, and how-do-I-do-that questions.",
            icon_color: "#9a8a3f", subforums: nil, lean: nil,
            threads: "88", posts: "601",
            last_post: { thread: "Can't upload avatar image", user: "ModeratorMike", user_color: GROUP_COLORS[:mod], time: "Yesterday, 04:18 PM", avatar_color: "#1e8449", initial: "M" }
          }
        ]
      }
    ]

    latest_posts_raw = [
      { is_reply: true, title: "Midterm predictions thread", user: "SunTzuFan", user_color: GROUP_COLORS[:senior], time: "Today, 11:52 AM", path: demo_thread_path },
      { is_reply: true, title: "Anyone else think the debate moderators were biased?", user: "popcorn_kev", user_color: GROUP_COLORS[:member], time: "Today, 11:40 AM" },
      { is_reply: false, title: "What are you watching tonight?", user: "popcorn_kev", user_color: GROUP_COLORS[:member], time: "Today, 10:37 AM" },
      { is_reply: true, title: "Best sources for unbiased polling data?", user: "PoliticalJunkie88", user_color: GROUP_COLORS[:senior], time: "Today, 10:12 AM" },
      { is_reply: true, title: "Scheduled maintenance this Tuesday", user: "Admin", user_color: GROUP_COLORS[:admin], time: "Today, 08:14 AM" },
      { is_reply: true, title: "Midterm predictions thread", user: "PoliticalJunkie88", user_color: GROUP_COLORS[:senior], time: "Today, 08:02 AM", path: demo_thread_path },
      { is_reply: false, title: "Hi all, long-time lurker here", user: "newbie_nancy", user_color: GROUP_COLORS[:member], time: "Yesterday, 09:02 PM" },
      { is_reply: true, title: "Can't upload avatar image", user: "ModeratorMike", user_color: GROUP_COLORS[:mod], time: "Yesterday, 04:18 PM" },
      { is_reply: true, title: "International Affairs mega-thread: Ukraine talks", user: "quietobserver", user_color: GROUP_COLORS[:member], time: "Yesterday, 06:40 PM" },
      { is_reply: true, title: "International Affairs mega-thread: Ukraine talks", user: "greyhawk_1979", user_color: GROUP_COLORS[:member], time: "Yesterday, 03:21 PM" },
      { is_reply: false, title: "Best sources for unbiased polling data?", user: "PoliticalJunkie88", user_color: GROUP_COLORS[:senior], time: "3 days ago" },
      { is_reply: true, title: "Forum Rules — Read Before Posting", user: "Admin", user_color: GROUP_COLORS[:admin], time: "2 months ago" },
      { is_reply: true, title: "What are you watching tonight?", user: "greyhawk_1979", user_color: GROUP_COLORS[:member], time: "4 days ago" },
      { is_reply: true, title: "Anyone else think the debate moderators were biased?", user: "newbie_nancy", user_color: GROUP_COLORS[:member], time: "4 days ago" },
      { is_reply: false, title: "Site feedback: dark mode when?", user: "quietobserver", user_color: GROUP_COLORS[:member], time: "5 days ago" }
    ]
    @latest_posts = latest_posts_raw.map { |p| p.merge(prefix: p[:is_reply] ? "RE:" : "") }

    @online_users = [
      { name: "Admin", group_color: GROUP_COLORS[:admin] },
      { name: "ModeratorMike", group_color: GROUP_COLORS[:mod] },
      { name: "PoliticalJunkie88", group_color: GROUP_COLORS[:senior] },
      { name: "popcorn_kev", group_color: GROUP_COLORS[:member] },
      { name: "newbie_nancy", group_color: GROUP_COLORS[:member] },
      { name: "greyhawk_1979", group_color: GROUP_COLORS[:member] },
      { name: "SunTzuFan", group_color: GROUP_COLORS[:senior] },
      { name: "quietobserver", group_color: GROUP_COLORS[:member] }
    ]
    @online_summary = "There are 47 users online: 12 members, 3 hidden, 32 guests."

    @stats = {
      threads: "8,214",
      posts: "178,679",
      members: "24,801",
      newest_member: "skeptical_sam"
    }
  end

  def show
    @breadcrumb = [
      { label: "Quorum", href: root_path },
      { label: "General Discussion" },
      { label: "Politics & Current Events", current: true }
    ]

    @forum = {
      title: "Politics & Current Events",
      description: "Debate the issues of the day. Keep it civil, or the mods will keep it for you.",
      subforums: [ "Elections 2026", "International Affairs" ]
    }

    @threads = [
      {
        marker: "📌", title: "Forum Rules — Read Before Posting", contested: false,
        author: "Admin", author_color: GROUP_COLORS[:admin], replies: "0", views: "12,204",
        last_post: { user: "Admin", user_color: GROUP_COLORS[:admin], time: "2 months ago", avatar_color: "#c0392b", initial: "A" }
      },
      {
        marker: "🔥", title: "Midterm predictions thread", contested: true,
        author: "PoliticalJunkie88", author_color: GROUP_COLORS[:senior], replies: "342", views: "18,204",
        last_post: { user: "SunTzuFan", user_color: GROUP_COLORS[:senior], time: "Today, 11:52 AM", avatar_color: "#7d97c2", initial: "S" }
      },
      {
        marker: nil, title: "International Affairs mega-thread: Ukraine talks", contested: false,
        author: "greyhawk_1979", author_color: GROUP_COLORS[:member], replies: "891", views: "44,102",
        last_post: { user: "quietobserver", user_color: GROUP_COLORS[:member], time: "Yesterday, 6:40 PM", avatar_color: "#a85050", initial: "Q" }
      },
      {
        marker: nil, title: "Anyone else think the debate moderators were biased?", contested: false,
        author: "newbie_nancy", author_color: GROUP_COLORS[:member], replies: "56", views: "2,301",
        last_post: { user: "popcorn_kev", user_color: GROUP_COLORS[:member], time: "Today, 09:15 AM", avatar_color: "#6b7aa8", initial: "K" }
      }
    ]

    @pages = pagination_pages(current: 1, last: 172)
  end
end
