class ForumThreadsController < ApplicationController
  GROUP_COLORS = ForumsController::GROUP_COLORS

  AFFILIATIONS = [
    { id: "progressive", name: "Progressive Alliance", color: "#6b4fa0", votes: 214 },
    { id: "liberty", name: "Liberty Caucus", color: "#a0524f", votes: 176 },
    { id: "centrist", name: "Centrist Coalition", color: "#4f8aa0", votes: 98 },
    { id: "independent", name: "Independent", color: "#7a7a7a", votes: 41 }
  ].freeze

  def show
    @breadcrumb = [
      { label: "Quorum", href: root_path },
      { label: "Politics & Current Events", href: forum_path(params[:forum_id]) },
      { label: "Midterm predictions thread", current: true }
    ]

    @thread_title = "Midterm predictions thread"

    total_votes = AFFILIATIONS.sum { |a| a[:votes] }
    @vote_choices = AFFILIATIONS.map { |a| a.merge(pct: total_votes.positive? ? ((a[:votes].to_f / total_votes) * 100).round : 0) }
    @vote_total = total_votes

    @posts = [
      {
        user: "PoliticalJunkie88", user_color: GROUP_COLORS[:senior], rank: "Senior Member",
        avatar_color: "#2455a4", initial: "P", joined: "Mar 2019", post_count: "4,821", reputation: "+312",
        time: "Today, 08:02 AM", number: "1", highlighted: false,
        affiliation_name: "Progressive Alliance", affiliation_color: "#6b4fa0", is_devils_advocate: true,
        ai_flag_reason: nil,
        signature: "\"Trust data, not headlines.\" — 4x Election Prediction Pool winner",
        body: "Alright, laying out my predictions for the midterms. I think we see a much tighter Senate race than the polls are suggesting right now — turnout in the suburbs is going to be the deciding factor, same as last cycle.\n\nCurious what everyone else is seeing on the ground in their districts."
      },
      {
        user: "SunTzuFan", user_color: GROUP_COLORS[:senior], rank: "Senior Member",
        avatar_color: "#7d97c2", initial: "S", joined: "Nov 2017", post_count: "9,043", reputation: "+588",
        time: "Today, 09:41 AM", number: "2", highlighted: false,
        affiliation_name: "Progressive Alliance", affiliation_color: "#6b4fa0", is_devils_advocate: false,
        ai_flag_reason: "Possible ad hominem detected — phrasing reads as directed at other posters rather than their argument.",
        signature: nil,
        body: "Turnout's the whole ballgame, agreed. The early voting numbers out west are already outpacing the last midterm by a wide margin, so something's clearly motivating people to show up early this time — unlike the people in this thread still peddling last cycle's talking points."
      },
      {
        user: "ModeratorMike", user_color: GROUP_COLORS[:mod], rank: "Moderator",
        avatar_color: "#1e8449", initial: "M", joined: "Jan 2015", post_count: "11,204", reputation: "+901",
        time: "Today, 11:52 AM", number: "3", highlighted: true,
        affiliation_name: nil, affiliation_color: nil, is_devils_advocate: false,
        ai_flag_reason: nil,
        signature: nil,
        body: "Reminder to everyone: keep the discussion focused on policy and turnout data rather than personal attacks on candidates or each other. A few posts have been edited for tone — let's keep it civil."
      }
    ]

    @pages = pagination_pages(current: 1, last: 115)
  end
end
