class ForumsController < ApplicationController
  ICON_COLORS = [ "#3f9142", "#a85050", "#8a8f9a", "#3f6fa0", "#9a8a3f" ].freeze

  def index
    @nav_current = :forums
    @bias_value = 38
    @posts_analyzed = "3,482"
    @bias_history = [ 44, 41, 47, 52, 49, 55, 58, 53, 46, 42, 39, 44, 48, 51 ]

    @categories = ForumCategory.ordered.map do |category|
      {
        name: category.title,
        forums: category.forums.top_level.ordered.map { |forum| forum_row_data(forum) }
      }
    end

    @latest_posts = latest_posts_data(limit: 15)

    @online_users = [
      { name: "Admin", group_color: "#c0392b" },
      { name: "ModeratorMike", group_color: "#1e8449" },
      { name: "PoliticalJunkie88", group_color: "#2455a4" },
      { name: "popcorn_kev", group_color: "#333333" },
      { name: "newbie_nancy", group_color: "#333333" },
      { name: "greyhawk_1979", group_color: "#333333" },
      { name: "SunTzuFan", group_color: "#2455a4" },
      { name: "quietobserver", group_color: "#333333" }
    ]
    @online_summary = "There are 47 users online: 12 members, 3 hidden, 32 guests."

    @stats = {
      threads: ForumThread.count.to_s,
      posts: (ForumThread.count + ThreadReply.count).to_s,
      members: User.count.to_s,
      newest_member: User.order(created_at: :desc).first&.display_name || "—"
    }
  end

  def show
    @nav_current = :forums
    @forum = Forum.friendly.find(params[:id])
    @subforums = @forum.subforums.ordered.map { |subforum| { name: subforum.title, path: forum_path(subforum) } }

    @breadcrumb = [
      { label: "Quorum", href: root_path },
      { label: @forum.forum_category.title },
      { label: @forum.title, current: true }
    ]

    page = paginate(@forum.forum_threads.order(created_at: :desc))
    @threads = page.records.map { |thread| thread_row_data(thread) }
    @pages = page_links(page, path: ->(number) { forum_path(@forum, page: number) })
  end

  private

  def forum_row_data(forum)
    threads_count = forum.forum_threads.count
    posts_count = threads_count + ThreadReply.joins(:forum_thread).where(forum_threads: { forum_id: forum.id }).count

    {
      name: forum.title,
      desc: forum.description,
      icon_color: ICON_COLORS[forum.index_order.to_i % ICON_COLORS.length],
      subforums: forum.subforums.ordered.pluck(:title).join(", ").presence,
      lean: nil,
      threads: threads_count.to_s,
      posts: posts_count.to_s,
      path: forum_path(forum),
      last_post: last_post_data(forum)
    }
  end

  def last_post_data(forum)
    latest_thread = forum.forum_threads.order(created_at: :desc).first
    latest_reply = ThreadReply.joins(:forum_thread).where(forum_threads: { forum_id: forum.id }).order(created_at: :desc).first
    latest = [ latest_thread, latest_reply ].compact.max_by(&:created_at)
    return nil unless latest

    thread = latest.is_a?(ThreadReply) ? latest.forum_thread : latest
    user = latest.user

    {
      thread: thread.title,
      user: user.display_name,
      user_color: user.rank_color,
      time: helpers.time_ago_in_words(latest.created_at) + " ago",
      avatar_color: user.avatar_color,
      initial: user.display_name.first.upcase,
      path: forum_thread_path(thread.forum, thread)
    }
  end

  def latest_posts_data(limit:)
    threads = ForumThread.order(created_at: :desc).limit(limit).map { |t| { record: t, is_reply: false, title: t.title, thread: t, created_at: t.created_at, user: t.user } }
    replies = ThreadReply.includes(forum_thread: :forum).order(created_at: :desc).limit(limit).map { |r| { record: r, is_reply: true, title: r.forum_thread.title, thread: r.forum_thread, created_at: r.created_at, user: r.user } }

    (threads + replies).sort_by { |p| -p[:created_at].to_f }.first(limit).map do |p|
      {
        prefix: p[:is_reply] ? "RE:" : "",
        title: p[:title],
        user: p[:user].display_name,
        user_color: p[:user].rank_color,
        time: helpers.time_ago_in_words(p[:created_at]) + " ago",
        path: forum_thread_path(p[:thread].forum, p[:thread])
      }
    end
  end

  def thread_row_data(thread)
    replies_count = thread.thread_replies.count
    last = thread.thread_replies.order(created_at: :desc).first || thread

    {
      marker: thread.is_sticky? ? "📌" : (replies_count >= 20 ? "🔥" : nil),
      slug: thread.slug,
      title: thread.title,
      contested: false,
      author: thread.user.display_name,
      author_color: thread.user.rank_color,
      replies: replies_count.to_s,
      views: thread.views_count.to_s,
      last_post: {
        user: last.user.display_name,
        user_color: last.user.rank_color,
        time: helpers.time_ago_in_words(last.created_at) + " ago",
        avatar_color: last.user.avatar_color,
        initial: last.user.display_name.first.upcase
      }
    }
  end
end
