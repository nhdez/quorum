class AiFlagsController < ApplicationController
  GROUP_COLORS = { admin: "#c0392b", mod: "#1e8449", senior: "#2455a4", member: "#333333" }.freeze

  def index
    @nav_current = :ai_flags

    @flags = [
      { thread: "Midterm predictions thread", excerpt: "...unlike the people in this thread still peddling last cycle's talking points.", reason: "Possible ad hominem — directed at other posters, not their argument.", user: "SunTzuFan", user_color: GROUP_COLORS[:senior], time: "Today, 09:41 AM" },
      { thread: "Anyone else think the debate moderators were biased?", excerpt: "...only someone completely out of touch would think that moderation was fair.", reason: "Possible ad hominem — dismisses others as “out of touch” rather than engaging the claim.", user: "newbie_nancy", user_color: GROUP_COLORS[:member], time: "Today, 09:15 AM" },
      { thread: "International Affairs mega-thread: Ukraine talks", excerpt: "...anyone still defending that policy hasn't been paying attention at all.", reason: "Possible loaded language — implies bad faith without addressing the specific point.", user: "greyhawk_1979", user_color: GROUP_COLORS[:member], time: "Yesterday, 6:52 PM" },
      { thread: "Best sources for unbiased polling data?", excerpt: "...that outlet is basically a propaganda arm at this point, so ignore anything from them.", reason: "Possible source dismissal without specific factual rebuttal.", user: "PoliticalJunkie88", user_color: GROUP_COLORS[:senior], time: "3 days ago" },
      { thread: "Off-Topic Lounge: What are you watching tonight?", excerpt: "...typical of someone with your political views to like a show like that.", reason: "Possible ad hominem — ties unrelated preference to political identity.", user: "quietobserver", user_color: GROUP_COLORS[:member], time: "4 days ago" }
    ]
  end
end
