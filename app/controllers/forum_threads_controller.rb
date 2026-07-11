class ForumThreadsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]
  before_action :set_max_word_count

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

    page = paginate(@thread.thread_replies.order(recommended: :desc, created_at: :asc))
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

  def set_max_word_count
    @max_word_count = PostSetting.instance.max_word_count
  end

  def thread_params
    params.require(:forum_thread).permit(:title, :body)
  end

  def post_view_data(post, number:)
    user = post.user
    earned_rank = user.current_rank

    {
      user: user.display_name,
      user_color: user.rank_color,
      rank: user.rank_label,
      earned_rank_name: earned_rank&.name,
      earned_rank_color: earned_rank&.badge_color,
      avatar_color: user.avatar_color,
      initial: user.display_name.first.upcase,
      flag: user.flag_emoji,
      country_name: user.country_name,
      joined: user.created_at.strftime("%b %Y"),
      post_count: user.post_count.to_s,
      time: post.created_at.strftime("%b %-d, %Y %l:%M %p").squeeze(" "),
      number: number.to_s,
      highlighted: user.has_role?(:admin),
      affiliation_name: user.faction&.name,
      affiliation_color: user.faction&.color,
      is_devils_advocate: false,
      ai_flag_reason: nil,
      signature: user.rendered_signature(viewer: current_user),
      body: post.body,
      fallacy_flags: fallacy_flags_data(post, user),
      recommended: post.recommended?,
      can_highlight: current_user.present? && (current_user.has_role?(:admin) || current_user.has_role?(:moderator)),
      highlight_path: toggle_highlight_path(highlightable_type: post.class.name, highlightable_id: post.id),
      votes_count: post.votes.count,
      voted_by_current_user: post.voted_by?(current_user),
      vote_path: current_user ? toggle_vote_path(votable_type: post.class.name, votable_id: post.id) : nil
    }
  end

  def fallacy_flags_data(post, author)
    return [] unless current_user == author || author.show_my_fallacy_flags_publicly?

    post.fallacy_flags.visible.includes(:fallacy_definition).map do |flag|
      {
        id: flag.id,
        fallacy_name: flag.fallacy_definition.display_name,
        excerpt: flag.excerpt,
        confidence: flag.confidence,
        dismissible: current_user == author,
        dismiss_path: dismiss_fallacy_flag_path(flag)
      }
    end
  end
end
