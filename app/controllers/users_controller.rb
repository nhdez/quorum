class UsersController < ApplicationController
  GROUP_COLORS = ForumsController::GROUP_COLORS

  def show
    @nav_current = :members

    @profile = {
      name: "PoliticalJunkie88", rank: "Senior Member", rank_color: GROUP_COLORS[:senior],
      initial: "P", avatar_color: "#2455a4", is_devils_advocate: true
    }

    @affiliation = { name: "Progressive Alliance", color: "#6b4fa0", is_rep: false }

    @stats = [
      { label: "Joined", value: "March 2019" },
      { label: "Last Active", value: "Today, 11:52 AM" },
      { label: "Total Posts", value: "4,821" },
      { label: "Threads Started", value: "212" },
      { label: "Reputation", value: "+312" },
      { label: "Likes Received", value: "1,904" }
    ]

    @about_me = "Longtime lurker turned poster. I follow election data way too closely and I will absolutely bring up turnout models in threads where nobody asked. Here mostly for the debates, occasionally for the off-topic lounge."
    @signature = "“Trust data, not headlines.” — 4x Election Prediction Pool winner"

    @recent_posts = [
      { thread: "Re: Midterm predictions thread", snippet: "Turnout in the suburbs is going to be the deciding factor, same as last cycle...", time: "Today, 08:02 AM" },
      { thread: "Re: International Affairs mega-thread: Ukraine talks", snippet: "Worth noting the talks stalled on the same sticking point as last round...", time: "Yesterday, 3:14 PM" },
      { thread: "Best sources for unbiased polling data?", snippet: "I've had good luck cross-referencing three or four aggregators rather than trusting just one...", time: "3 days ago" }
    ]
  end
end
