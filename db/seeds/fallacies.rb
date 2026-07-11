# db/seeds/fallacies.rb
#
# Seeds the default catalog of 24 fallacy definitions.
# Run with: bin/rails runner db/seeds/fallacies.rb
#
# Descriptions are written independently for this project; they are not
# copied text from any external source. Admins can edit, disable, or add
# to this list after seeding — this file only sets sensible defaults.

FALLACIES = [
  {
    key: "strawman",
    display_name: "Strawman",
    short_description: "Misrepresents an argument to make it easier to knock down.",
    long_description: "Restates or exaggerates someone's position into a weaker, distorted version, then attacks that version instead of what was actually said.",
    detection_prompt_fragment: "Flag STRAWMAN when a reply mischaracterizes or exaggerates a previous poster's stated position before rebutting it, rather than addressing what was actually written.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "medium"
  },
  {
    key: "false_cause",
    display_name: "False Cause",
    short_description: "Assumes that because two things correlate, one caused the other.",
    long_description: "Treats a coincidental or merely correlated relationship between two events or trends as evidence of a causal link, without ruling out other explanations.",
    detection_prompt_fragment: "Flag FALSE_CAUSE when a post infers causation from correlation or coincidence, especially citing trends or timing as proof of cause.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "medium"
  },
  {
    key: "appeal_to_emotion",
    display_name: "Appeal to Emotion",
    short_description: "Substitutes an emotional appeal for an actual argument.",
    long_description: "Attempts to win agreement by provoking pity, fear, anger, or other feelings rather than presenting evidence or valid reasoning.",
    detection_prompt_fragment: "Flag APPEAL_TO_EMOTION when a post relies primarily on emotional language or imagery to persuade, in place of evidence or logical support.",
    default_enabled: true,
    default_confidence_threshold: 0.55,
    default_severity: "low"
  },
  {
    key: "the_fallacy_fallacy",
    display_name: "The Fallacy Fallacy",
    short_description: "Assumes a poorly argued claim must be false.",
    long_description: "Concludes that because an argument for a claim was flawed or contained a fallacy, the claim itself must be wrong — even though bad arguments can still support true conclusions.",
    detection_prompt_fragment: "Flag THE_FALLACY_FALLACY when a poster dismisses a claim as false solely because the argument for it was poorly constructed or itself fallacious.",
    default_enabled: true,
    default_confidence_threshold: 0.65,
    default_severity: "low"
  },
  {
    key: "slippery_slope",
    display_name: "Slippery Slope",
    short_description: "Claims a small first step will inevitably lead to extreme consequences.",
    long_description: "Asserts that allowing one relatively modest action will set off an unstoppable chain leading to a drastic and usually undesirable outcome, without justifying each step.",
    detection_prompt_fragment: "Flag SLIPPERY_SLOPE when a post argues that a minor action or policy will inevitably cascade into extreme consequences, without establishing the intermediate steps.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "medium"
  },
  {
    key: "ad_hominem",
    display_name: "Ad Hominem",
    short_description: "Attacks the person instead of the argument.",
    long_description: "Responds to an argument by attacking the character, motives, or traits of the person making it, rather than engaging with the substance of what they said.",
    detection_prompt_fragment: "Flag AD_HOMINEM when a reply attacks the poster's character, credibility, or personal traits instead of addressing the argument they made.",
    default_enabled: true,
    default_confidence_threshold: 0.55,
    default_severity: "high"
  },
  {
    key: "tu_quoque",
    display_name: "Tu Quoque",
    short_description: "Deflects criticism by accusing the critic of the same thing.",
    long_description: "Responds to a valid criticism not by addressing it, but by pointing out that the critic is guilty of the same or a similar fault.",
    detection_prompt_fragment: "Flag TU_QUOQUE when a poster deflects a criticism by turning it back on the critic ('you do it too') instead of responding to the substance.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "medium"
  },
  {
    key: "personal_incredulity",
    display_name: "Personal Incredulity",
    short_description: "Rejects a claim just because it's hard to personally imagine.",
    long_description: "Concludes something is false or implausible solely on the grounds that the speaker personally finds it difficult to understand or believe.",
    detection_prompt_fragment: "Flag PERSONAL_INCREDULITY when a poster dismisses a claim mainly on the basis that they personally find it hard to believe or understand, without further evidence.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "low"
  },
  {
    key: "special_pleading",
    display_name: "Special Pleading",
    short_description: "Invents a exception to save a claim after it's been challenged.",
    long_description: "Moves the goalposts or introduces an ad hoc exception specifically to protect a claim once evidence has shown it to be false or inconsistent.",
    detection_prompt_fragment: "Flag SPECIAL_PLEADING when a poster introduces a new exception or condition to a claim only after that claim has been challenged, in order to preserve it.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "medium"
  },
  {
    key: "loaded_question",
    display_name: "Loaded Question",
    short_description: "Asks a question with a built-in, unproven assumption.",
    long_description: "Poses a question that presupposes something not yet established, such that any direct answer implicitly concedes the embedded assumption.",
    detection_prompt_fragment: "Flag LOADED_QUESTION when a question embeds an unproven assumption such that answering it directly concedes that assumption.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "medium"
  },
  {
    key: "bandwagon",
    display_name: "Bandwagon",
    short_description: "Treats popularity as proof of correctness.",
    long_description: "Argues that a claim must be true, or a course of action correct, mainly because many people believe or do it.",
    detection_prompt_fragment: "Flag BANDWAGON when a post appeals to the popularity of a belief or practice as evidence of its truth or validity.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "low"
  },
  {
    key: "appeal_to_authority",
    display_name: "Appeal to Authority",
    short_description: "Leans on an authority's opinion in place of actual evidence.",
    long_description: "Uses the opinion or status of an authority figure or institution as if it settled the argument, especially when that authority's expertise doesn't clearly apply to the claim at hand.",
    detection_prompt_fragment: "Flag APPEAL_TO_AUTHORITY when a post relies on the status or opinion of an authority figure in place of supporting evidence, particularly when the authority's relevant expertise is unclear.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "medium"
  },
  {
    key: "composition_division",
    display_name: "Composition / Division",
    short_description: "Wrongly assumes a whole shares a part's traits, or vice versa.",
    long_description: "Assumes that something true of a part must be true of the whole (composition), or that something true of the whole must be true of each part (division).",
    detection_prompt_fragment: "Flag COMPOSITION_DIVISION when a post assumes a property of one part automatically applies to the entire whole, or the reverse.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "low"
  },
  {
    key: "anecdotal",
    display_name: "Anecdotal",
    short_description: "Uses a personal story in place of solid evidence.",
    long_description: "Relies on a single personal experience or isolated example instead of representative evidence or statistics, especially to dismiss broader data.",
    detection_prompt_fragment: "Flag ANECDOTAL when a post substitutes a personal anecdote or isolated example for statistical or representative evidence, especially to override broader data.",
    default_enabled: true,
    default_confidence_threshold: 0.55,
    default_severity: "low"
  },
  {
    key: "no_true_scotsman",
    display_name: "No True Scotsman",
    short_description: "Redefines a group to exclude an inconvenient example.",
    long_description: "Protects a generalization about a group by insisting that any counterexample simply isn't a 'real' or 'true' member of that group.",
    detection_prompt_fragment: "Flag NO_TRUE_SCOTSMAN when a poster dismisses a counterexample to a group generalization by claiming the example isn't a genuine member of that group.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "medium"
  },
  {
    key: "the_texas_sharpshooter",
    display_name: "The Texas Sharpshooter",
    short_description: "Cherry-picks data that fits a pattern, ignoring the rest.",
    long_description: "Focuses only on the data points that support a chosen conclusion while disregarding contradicting data, creating the illusion of a meaningful pattern.",
    detection_prompt_fragment: "Flag THE_TEXAS_SHARPSHOOTER when a post selectively cites supporting data points while ignoring readily available contradicting data, to manufacture a pattern.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "medium"
  },
  {
    key: "middle_ground",
    display_name: "Middle Ground",
    short_description: "Assumes the truth must lie between two opposing claims.",
    long_description: "Concludes that a compromise between two extremes must be correct simply because it sits in between them, regardless of the actual evidence for either side.",
    detection_prompt_fragment: "Flag MIDDLE_GROUND when a post assumes a compromise position between two claims is correct merely because it's a midpoint, without evidence supporting that middle position.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "low"
  },
  {
    key: "burden_of_proof",
    display_name: "Burden of Proof",
    short_description: "Shifts the responsibility to disprove a claim onto others.",
    long_description: "Places the obligation to disprove a claim on the listener rather than on the person making the original assertion, who bears the actual burden of proof.",
    detection_prompt_fragment: "Flag BURDEN_OF_PROOF when a poster makes a claim and insists others disprove it, rather than supporting the claim themselves.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "medium"
  },
  {
    key: "ambiguity",
    display_name: "Ambiguity",
    short_description: "Uses vague or double-meaning language to mislead.",
    long_description: "Exploits unclear, vague, or multiple-meaning wording to make an argument seem more valid than it is, or to dodge a direct commitment.",
    detection_prompt_fragment: "Flag AMBIGUITY when a post uses vague or double-meaning phrasing in a way that misleads or obscures the actual claim being made.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "low"
  },
  {
    key: "the_gamblers_fallacy",
    display_name: "The Gambler's Fallacy",
    short_description: "Believes past random outcomes affect future independent ones.",
    long_description: "Assumes that a run of outcomes in an independent random process makes a different outcome 'due,' when each event is actually statistically unaffected by the last.",
    detection_prompt_fragment: "Flag THE_GAMBLERS_FALLACY when a post assumes that a streak of independent random outcomes changes the odds of the next, unrelated outcome.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "low"
  },
  {
    key: "genetic",
    display_name: "Genetic",
    short_description: "Judges a claim by its origin rather than its merits.",
    long_description: "Accepts or rejects an argument based on where it came from or who said it, rather than evaluating the argument on its own evidence.",
    detection_prompt_fragment: "Flag GENETIC when a post's judgment of a claim rests on its source or origin rather than the substance of the claim itself.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "low"
  },
  {
    key: "black_or_white",
    display_name: "Black-or-White",
    short_description: "Presents only two options when more actually exist.",
    long_description: "Frames a situation as having only two possible outcomes or positions, when in reality a range of other options exists.",
    detection_prompt_fragment: "Flag BLACK_OR_WHITE when a post presents only two extreme options as the sole possibilities, while other real options exist.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "medium"
  },
  {
    key: "begging_the_question",
    display_name: "Begging the Question",
    short_description: "An argument whose conclusion is assumed in its own premise.",
    long_description: "Constructs an argument in which the conclusion is already assumed within the premise, so the argument doesn't actually prove anything.",
    detection_prompt_fragment: "Flag BEGGING_THE_QUESTION when an argument's premise already assumes the truth of its own conclusion, offering no independent support.",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "medium"
  },
  {
    key: "appeal_to_nature",
    display_name: "Appeal to Nature",
    short_description: "Assumes natural things are automatically good or right.",
    long_description: "Argues that because something is 'natural,' it must be valid, healthy, or justified — and conversely that 'unnatural' things must be bad.",
    detection_prompt_fragment: "Flag APPEAL_TO_NATURE when a post argues something is good, valid, or justified mainly because it is 'natural,' or bad because it is 'unnatural.'",
    default_enabled: true,
    default_confidence_threshold: 0.6,
    default_severity: "low"
  }
].freeze

FALLACIES.each do |attrs|
  definition = FallacyDefinition.find_or_initialize_by(key: attrs[:key])
  definition.assign_attributes(attrs)
  definition.save!
  puts "Seeded fallacy: #{attrs[:display_name]}"
end

puts "Done. #{FALLACIES.size} fallacy definitions seeded."
