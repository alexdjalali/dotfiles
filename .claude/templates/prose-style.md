# Prose Style

For every written artifact: ADRs, design docs, epics and stories, RCAs, audits, plans, PR and commit bodies, skills, READMEs, doc comments. The template owns the structure; this file governs the sentences inside it. Chat replies follow `rules/communication.md`.

## Written for a person first

An agent can read anything a person can read, so write for the person. A teammate who hasn't seen the code should understand what is changing and why from the opening section alone.

- **Open with the outcome in plain language:** the problem, what changes, who notices. Code identifiers come after.
- **Full sentences in descriptions.** Reserve fragments for tables, checklists, and labels. No arrows, `·` chains, or `=` standing in for a verb.
- **Spell things out.** Define an abbreviation or internal term at first use. Write "Decisions 2", not "D2". No private codes, such as `G1`, in prose without saying what they are.
- **One fact per line in headers.** Never several labeled fields on one line.
- **Be explicit.** State the condition, the actor, and the result. "Retry it" becomes "The worker retries the upload three times, then marks the job failed."
- **Implementer detail goes last,** under its own heading, so a reader can stop early.

## Principles

- **Concrete beats abstract.** Names, numbers, `file:line`, mechanisms. "Improved efficiency" → "cut deploy time from 40 min to 4".
- **Portability test.** A sentence that could move unchanged to another project, team, or product is filler: cut it or replace it with a fact, mechanism, consequence, or judgment specific to this one.
- **Show, don't label.** Let facts and consequences carry the weight. Cut commentary that calls a point important, subtle, or obvious.
- **Active voice, human or code subjects.** "The scheduler retries the job", not "a retry is performed". Inanimate things don't decide, believe, or embrace.
- **Direct verbs.** "made a decision" → "decided"; "has the ability to" → "can"; "serves as" → "is".
- **One term per concept.** Repeat the right word; don't rotate synonyms (agent / assistant / tool) for variety.
- **Don't invent.** No claims, numbers, or sources the evidence doesn't support. No source → name the gap; never "studies show".
- **Editing someone else's prose:** make the minimum effective edit. Fix what is wrong or unclear; leave accurate, characteristic sentences and the author's voice alone.

## Cut

**Words:** delve, foster, leverage, utilize, facilitate, empower, streamline, robust, cutting-edge, seamless, paradigm shift, game changer, tapestry, realm, beacon, multifaceted, meticulous, intricate, paramount, transformative, elevate, embark, supercharge, harness, ever-evolving. Empty adverbs (just, simply, actually, truly, fundamentally, crucially, inherently) unless they carry contrast or uncertainty.

**Phrases:** it's worth noting, it's important to note, at the end of the day, when it comes to, at its core, in today's world, the reality is, in terms of, in order to, going forward, let's dive in.

**Patterns:**

| Pattern | Example | Fix |
|---|---|---|
| Binary contrast / negative listing | "It's not X, it's Y." · "Not A. Not B. C." | State Y (or C) directly |
| Throat-clearing / faux insight | "Here's the thing", "what most people miss" | Cut; make the claim |
| Colon reveal | "The best part: it learns." | Plain sentence; colons for lists, labels, code |
| Superficial `-ing` analysis | "…, highlighting our commitment to quality" | State the actual consequence or cut |
| Importance puffery | "a pivotal moment", "plays a vital role" | The fact; let the reader judge |
| Metadiscourse | "As you can see", "this distinction matters" | Delete |
| Weasel attribution | "experts agree", "widely regarded" | Name the source or cut |
| Rhetorical setup | "What if…?", "Plot twist:", self-answered questions | Make the point |
| Dramatic fragments / robotic rhythm | "That's it. That's the whole thing." | Complete sentences; vary shape only when it helps |
| Fake-profound kicker / recap ending | "Ultimately…", a closing aphorism | End on the last concrete point or next action |
| Formatting slop | Emoji headings, decorative mid-sentence bold, bullets for two sentences, a header over two lines | Format follows content |

## Self-check before writing the file

Scan the draft once against **Cut** and the portability test. Every hit gets fixed, not explained. Quoted examples and code are exempt.
