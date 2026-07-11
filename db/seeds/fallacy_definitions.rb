# The 24 fallacies from the "thou shalt not commit logical fallacies"
# reference (yourfallacy.is / The School of Thought). Idempotent — safe
# to re-run.

FALLACY_DEFINITIONS = [
  {
    key: "strawman",
    display_name: "Straw Man",
    short_description: "Misrepresenting someone's argument to make it easier to attack.",
    long_description: "By exaggerating, misrepresenting, or just completely fabricating someone's argument, it's much easier to present your own position as being reasonable, but this kind of dishonesty ruins productive debate.",
    detection_prompt_fragment: "strawman: The post restates an opponent's position in an exaggerated or distorted way, then attacks that distorted version instead of the real argument."
  },
  {
    key: "false_cause",
    display_name: "False Cause",
    short_description: "Assuming a real or perceived relationship between things means one caused the other.",
    long_description: "Presuming that a real or perceived relationship between two things means that one is the cause of the other, when correlation does not necessarily imply causation.",
    detection_prompt_fragment: "false_cause: The post treats a correlation, sequence, or coincidence between two events as proof that one caused the other, without establishing an actual causal mechanism."
  },
  {
    key: "appeal_to_emotion",
    display_name: "Appeal to Emotion",
    short_description: "Manipulating an emotional response in place of a valid argument.",
    long_description: "Attempting to manipulate an emotional response in place of a valid or compelling argument. Appeals to emotion include appeals to fear, envy, hatred, pity, pride, and more.",
    detection_prompt_fragment: "appeal_to_emotion: The post relies primarily on provoking fear, anger, pity, or outrage to win agreement, rather than presenting evidence or reasoning."
  },
  {
    key: "the_fallacy_fallacy",
    display_name: "The Fallacy Fallacy",
    short_description: "Presuming a claim is wrong because it was poorly argued.",
    long_description: "Presuming that because a claim has been poorly argued, or a fallacy has been made, that the claim itself must be wrong. It is entirely possible to make a claim that is true yet argue for that claim poorly.",
    detection_prompt_fragment: "the_fallacy_fallacy: The post dismisses a conclusion as false solely because the argument for it contained a flaw or fallacy, without addressing whether the underlying claim could still be true."
  },
  {
    key: "slippery_slope",
    display_name: "Slippery Slope",
    short_description: "Asserting a relatively small step leads to a chain of extreme events.",
    long_description: "Asserting that if we allow A to happen, then Z will eventually happen too, therefore A should not happen, without establishing that the intermediate steps are actually likely.",
    detection_prompt_fragment: "slippery_slope: The post claims a small first step will inevitably lead to a chain of increasingly extreme consequences, without justifying why each step in the chain would actually follow."
  },
  {
    key: "ad_hominem",
    display_name: "Ad Hominem",
    short_description: "Attacking a person's character instead of engaging with their argument.",
    long_description: "Attacking your opponent's character or personal traits in an attempt to undermine their argument, rather than engaging with the substance of what they said.",
    detection_prompt_fragment: "ad_hominem: The post attacks the character, motives, or personal traits of the person making an argument, rather than engaging with the argument itself."
  },
  {
    key: "tu_quoque",
    display_name: "Tu Quoque",
    short_description: "Avoiding criticism by turning it back on the accuser (\"you too\").",
    long_description: "Avoiding having to engage with criticism by turning it back on the accuser — answering criticism with criticism, rather than a defense of the original position.",
    detection_prompt_fragment: "tu_quoque: The post deflects a criticism by pointing out that the critic is guilty of the same or a similar fault, rather than addressing the original criticism."
  },
  {
    key: "personal_incredulity",
    display_name: "Personal Incredulity",
    short_description: "Saying something must be false because it's hard to understand.",
    long_description: "Saying that because one finds something difficult to understand, it's therefore not true, substituting personal complexity for an actual argument against it.",
    detection_prompt_fragment: "personal_incredulity: The post argues a claim must be false or absurd purely because the author finds it hard to imagine or understand, without offering a substantive counter-argument."
  },
  {
    key: "special_pleading",
    display_name: "Special Pleading",
    short_description: "Moving the goalposts or claiming an exception without justification.",
    long_description: "Moving the goalposts or making an exception to a generally accepted rule or principle without adequate justification, usually to protect a favored position from counter-evidence.",
    detection_prompt_fragment: "special_pleading: The post applies a standard or rule to others but claims an unjustified exception for itself, its side, or its preferred position when counter-evidence arises."
  },
  {
    key: "loaded_question",
    display_name: "Loaded Question",
    short_description: "Asking a question with a built-in assumption so it can't be answered without appearing guilty.",
    long_description: "Asking a question that has an assumption built into it, so it can't be answered without appearing guilty. Loaded questions are often used to trap someone into a corner.",
    detection_prompt_fragment: "loaded_question: The post poses a question that presupposes something the target hasn't agreed to, structured so any direct answer appears to confirm a negative claim."
  },
  {
    key: "black_or_white",
    display_name: "Black-or-White",
    short_description: "Presenting only two options when more exist.",
    long_description: "Presenting two alternative states as the only possibilities, when in fact more possibilities exist, oversimplifying a nuanced issue into a false binary.",
    detection_prompt_fragment: "black_or_white: The post frames an issue as having only two possible options or outcomes, when other reasonable positions clearly exist."
  },
  {
    key: "bandwagon",
    display_name: "Bandwagon",
    short_description: "Appealing to popularity or the fact that many people do something as validation.",
    long_description: "Appealing to popularity or the fact that many people do something as an attempted form of validation — the assumption that the more people believe something, the more likely it is to be true.",
    detection_prompt_fragment: "bandwagon: The post argues a claim is true or an action is right primarily because many people believe it or do it, rather than on the claim's own merits."
  },
  {
    key: "appeal_to_authority",
    display_name: "Appeal to Authority",
    short_description: "Citing an authority figure instead of an actual argument.",
    long_description: "Saying that because an authority figure believes something, it must therefore be true, without regard to whether that authority is actually qualified on the specific topic, or presenting real evidence.",
    detection_prompt_fragment: "appeal_to_authority: The post argues a claim is true mainly because an authority figure or credentialed person endorses it, without citing the actual evidence or reasoning behind that endorsement."
  },
  {
    key: "composition_division",
    display_name: "Composition / Division",
    short_description: "Assuming what's true of a part is true of the whole, or vice versa.",
    long_description: "Assuming that one part of something has to apply to all, or other, parts of it; or that the whole must apply to its parts, when this isn't necessarily true.",
    detection_prompt_fragment: "composition_division: The post assumes a property of one member or part of a group must apply to the whole group (or the reverse), without justification."
  },
  {
    key: "anecdotal",
    display_name: "Anecdotal",
    short_description: "Using personal experience or an isolated example instead of sound evidence.",
    long_description: "Using personal experience or an isolated example instead of a valid argument, especially to dismiss statistics or a well-established pattern.",
    detection_prompt_fragment: "anecdotal: The post relies on a single personal story or isolated example as the primary support for a general claim, especially where it dismisses broader statistical evidence."
  },
  {
    key: "texas_sharpshooter",
    display_name: "The Texas Sharpshooter",
    short_description: "Cherry-picking data clusters to fit a conclusion.",
    long_description: "Cherry-picking data clusters to suit an argument, or finding a pattern to fit a presumption, while ignoring data that contradicts that pattern.",
    detection_prompt_fragment: "texas_sharpshooter: The post selectively highlights a cluster of favorable data points or examples while ignoring unfavorable ones, to manufacture the appearance of a pattern."
  },
  {
    key: "middle_ground",
    display_name: "Middle Ground",
    short_description: "Assuming a compromise between two positions must be correct.",
    long_description: "Claiming that a compromise, or middle point, between two extremes must be the truth, when in fact one extreme (or neither) may be correct.",
    detection_prompt_fragment: "middle_ground: The post argues that the truth must lie at some compromise point between two positions, purely because they are opposing positions."
  },
  {
    key: "burden_of_proof",
    display_name: "Burden of Proof",
    short_description: "Insisting the other side must disprove a claim rather than proving it.",
    long_description: "Saying that the burden of proof lies not with the person making the claim, but with someone else to disprove it — reversing who is responsible for providing evidence.",
    detection_prompt_fragment: "burden_of_proof: The post asserts a claim and insists others must disprove it, rather than the claimant providing evidence for it."
  },
  {
    key: "ambiguity",
    display_name: "Ambiguity",
    short_description: "Using double meaning or vagueness to mislead or misrepresent the truth.",
    long_description: "Using double meanings or ambiguities of language to mislead or misrepresent the truth, shifting the meaning of a key term partway through an argument.",
    detection_prompt_fragment: "ambiguity: The post exploits a word or phrase's shifting or vague meaning partway through the argument to make the reasoning appear to hold together."
  },
  {
    key: "no_true_scotsman",
    display_name: "No True Scotsman",
    short_description: "Redefining a category to exclude a counter-example after the fact.",
    long_description: "Making what could be called an appeal to purity, as a way to dismiss relevant criticisms or flaws of an argument by redefining the category to exclude the counter-example, rather than addressing it.",
    detection_prompt_fragment: "no_true_scotsman: When given a counter-example to a generalization, the post redefines the category ('no true X would...') to exclude the counter-example instead of revising the claim."
  },
  {
    key: "genetic",
    display_name: "Genetic Fallacy",
    short_description: "Judging something as good or bad based on its origin.",
    long_description: "Judging something as either good or bad on the basis of where it comes from, or from whom it came, rather than on its own merit.",
    detection_prompt_fragment: "genetic: The post accepts or rejects a claim based on its source or origin (who said it, where it came from) rather than evaluating the claim itself."
  },
  {
    key: "begging_the_question",
    display_name: "Begging the Question",
    short_description: "A circular argument where the conclusion is included in the premise.",
    long_description: "A circular argument in which the conclusion is included in the premise, presenting a claim as its own justification without providing actual independent support.",
    detection_prompt_fragment: "begging_the_question: The post's argument assumes the truth of its own conclusion as one of its premises, so the reasoning is circular."
  },
  {
    key: "appeal_to_nature",
    display_name: "Appeal to Nature",
    short_description: "Arguing something is good because it's natural, or bad because unnatural.",
    long_description: "Making the argument that because something is 'natural,' it is therefore valid, justified, inevitable, or good — or the reverse, that something 'unnatural' must be bad.",
    detection_prompt_fragment: "appeal_to_nature: The post argues a position is good/valid because it is 'natural,' or bad/invalid because it is 'unnatural,' without further justification."
  },
  {
    key: "gamblers_fallacy",
    display_name: "The Gambler's Fallacy",
    short_description: "Believing past independent events affect future independent probabilities.",
    long_description: "Believing that 'runs' occur to statistically independent phenomena, such as roulette wheel spins — the false belief that past outcomes affect future probabilities of an independent event.",
    detection_prompt_fragment: "gamblers_fallacy: The post assumes that a string of past, statistically independent outcomes changes the probability of the next independent outcome."
  }
].freeze

FALLACY_DEFINITIONS.each do |attrs|
  FallacyDefinition.find_or_create_by!(key: attrs[:key]) do |definition|
    definition.assign_attributes(attrs)
  end
end

puts "Seeded #{FallacyDefinition.count} fallacy definitions."
