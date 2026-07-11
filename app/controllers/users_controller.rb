class UsersController < ApplicationController
  def show
    @nav_current = :members
    @user = User.find(params[:id])
    earned_rank = @user.current_rank

    @profile = {
      name: @user.display_name,
      rank: @user.rank_label,
      rank_color: @user.rank_color,
      initial: @user.display_name.first.upcase,
      avatar_color: @user.avatar_color,
      is_devils_advocate: false
    }

    @affiliation = if @user.faction
      { name: @user.faction.name, color: @user.faction.color, is_rep: false }
    end

    @stats = [
      { label: "Joined", value: @user.created_at.strftime("%B %Y") },
      { label: "Total Posts", value: @user.post_count.to_s },
      { label: "Threads Started", value: @user.forum_threads.count.to_s },
      { label: "Votes Received", value: @user.received_votes_count.to_s }
    ]
    @stats << { label: "Rank", value: earned_rank.name } if earned_rank

    @about_me = "This member hasn't written a bio yet."
    @signature = nil

    @recent_posts = recent_posts_for(@user)
    @notifications = @user.notifications.newest_first.limit(20) if current_user == @user
  end

  private

  def recent_posts_for(user)
    threads = user.forum_threads.order(created_at: :desc).limit(3).map do |thread|
      recent_post_data(thread.title, thread.body, thread.created_at, forum_thread_path(thread.forum, thread))
    end

    replies = user.thread_replies.includes(forum_thread: :forum).order(created_at: :desc).limit(3).map do |reply|
      recent_post_data(reply.forum_thread.title, reply.body, reply.created_at, forum_thread_path(reply.forum_thread.forum, reply.forum_thread))
    end

    (threads + replies).sort_by { |post| -post[:created_at].to_f }.first(3).each { |post| post.delete(:created_at) }
  end

  def recent_post_data(thread_title, body, created_at, path)
    {
      thread: thread_title,
      snippet: body.to_plain_text.truncate(140),
      time: created_at.strftime("%b %-d, %Y"),
      path: path,
      created_at: created_at
    }
  end
end
