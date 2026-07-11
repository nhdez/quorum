class ForumThreadsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]

  AFFILIATIONS = [
    { id: "progressive", name: "Progressive Alliance", color: "#6b4fa0", votes: 214 },
    { id: "liberty", name: "Liberty Caucus", color: "#a0524f", votes: 176 },
    { id: "centrist", name: "Centrist Coalition", color: "#4f8aa0", votes: 98 },
    { id: "independent", name: "Independent", color: "#7a7a7a", votes: 41 }
  ].freeze

  def show
    @nav_current = :forums
    @forum = Forum.friendly.find(params[:forum_id])
    @thread = @forum.forum_threads.friendly.find(params[:id])
    @thread.increment!(:views_count)

    @breadcrumb = [
      { label: "Quorum", href: root_path },
      { label: @forum.title, href: forum_path(@forum) },
      { label: @thread.title, current: true }
    ]

    @thread_title = @thread.title

    total_votes = AFFILIATIONS.sum { |a| a[:votes] }
    @vote_choices = AFFILIATIONS.map { |a| a.merge(pct: total_votes.positive? ? ((a[:votes].to_f / total_votes) * 100).round : 0) }
    @vote_total = total_votes

    page = paginate(@thread.thread_replies.order(:created_at))
    @posts = [ post_view_data(@thread, number: 1) ] + page.records.each_with_index.map { |reply, i| post_view_data(reply, number: i + 2) }
    @pages = page_links(page, path: ->(number) { forum_thread_path(@forum, @thread, page: number) })
  end

  def new
    @forum = Forum.friendly.find(params[:forum_id])
    @thread = @forum.forum_threads.build
  end

  def create
    @forum = Forum.friendly.find(params[:forum_id])
    @thread = @forum.forum_threads.build(thread_params)
    @thread.user = current_user

    if @thread.save
      redirect_to forum_thread_path(@forum, @thread), notice: "Thread created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def thread_params
    params.require(:forum_thread).permit(:title, :body)
  end

  def post_view_data(post, number:)
    user = post.user

    {
      user: user.display_name,
      user_color: user.rank_color,
      rank: user.rank_label,
      avatar_color: user.avatar_color,
      initial: user.display_name.first.upcase,
      joined: user.created_at.strftime("%b %Y"),
      post_count: user.post_count.to_s,
      time: post.created_at.strftime("%b %-d, %Y %l:%M %p").squeeze(" "),
      number: number.to_s,
      highlighted: user.has_role?(:admin),
      affiliation_name: user.faction&.name,
      affiliation_color: user.faction&.color,
      is_devils_advocate: false,
      ai_flag_reason: nil,
      signature: nil,
      body: post.body
    }
  end
end
