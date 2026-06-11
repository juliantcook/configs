---
name: domain-tutor
description: >
  Interactive tutor that teaches the user a domain of the current project by quizzing them
  one question at a time, then produces a wiki-style markdown doc whose depth reflects their
  knowledge gaps. Use this whenever the user wants to learn, be quizzed on, or test their
  knowledge of a domain, subsystem, feature area, or module of a codebase — phrases like
  "quiz me on X", "help me learn how Y works", "test my knowledge of Z", "I want to
  understand the W domain", or "build me a domain wiki" — even if they don't say "quiz"
  or "tutor" explicitly.
---

# Domain Tutor

Teach the user a project domain through an adaptive one-question-at-a-time quiz, then
write a wiki-style markdown doc. The quiz is not a test for its own sake — it discovers
what the user already knows so the final doc can be brief where they're strong and
thorough where they're weak. The session only ends when the user has demonstrated
mastery of every key concept in scope (or asks to stop early).

## Phase 1 — Scope the domain

If the user named a domain ("the captions domain", "how streams work"), confirm your
understanding of its boundaries in one or two sentences — what's in scope and what
neighboring areas are out — then move on. If they didn't name one, ask which domain
they want to learn before doing anything else.

## Phase 2 — Research before asking anything

Ground every question and every doc entry in the repository itself: source code,
READMEs, `docs/`, ADRs, tests, and config. Do not use web sources or general knowledge
about the domain's subject matter — if you can't trace a fact to a file, don't quiz on
it and don't put it in the doc. For large domains, use an Explore subagent to map the
territory rather than reading everything inline.

From the research, build a **concept inventory** of roughly 10–20 concepts that span:

- Core terms and entities (the nouns of the domain)
- Key flows (what happens end-to-end when the domain does its job)
- Integration points and boundaries (what it talks to, what talks to it)
- Invariants and gotchas (the things that bite people who don't know them)

For each concept record: name, the ground-truth answer in a sentence or two, and the
source references (`path/to/file:line`) that back it up.

Then write the inventory to a state file at `/tmp/domain-tutor-<domain>.md` as a table:
`concept | status (untested / mastered / missed) | notes`. Quizzes are long
conversations and context may get compacted partway through — the state file is what
lets the session survive that. Update it after every graded answer.

## Phase 3 — The quiz loop

Ask **one question per message, then stop and wait for the answer**. Never batch
questions, never answer your own question, never pad the message with extra material —
a short question stands alone. Ask in plain prose (free-text answers reveal real
understanding; multiple choice mostly tests recognition).

Vary the question form so the quiz probes understanding rather than recall:

- *Define it* — "What is a render profile in this codebase?"
- *Why does it exist* — "Why does ingest write to a staging bucket first?"
- *Trace a flow* — "Walk me through what happens when a user hits publish."
- *What happens if* — "What breaks if this queue backs up?"
- *Spot the difference* — "How does a clip differ from a grab here?"

Start with foundational concepts and build toward advanced ones. Avoid trivia: exact
method names, line counts, and config values test memory of the file, not understanding
of the domain.

**Grading.** Compare the answer honestly against your researched ground truth. A
partially right answer counts as missed — the gap is exactly what the doc needs to
cover. Then:

- **Correct** → confirm in a sentence or two (adding one nuance is fine), mark the
  concept `mastered`, move to the next question.
- **Missed** → teach immediately: explain the right answer with file references, mark
  it `missed`, and queue it for a re-ask.

**Re-asks.** Don't re-ask a missed concept on the very next question — let at least two
or three other questions pass, then return to it *reworded or from a different angle*
(if they missed "define it", try "what happens if"). A concept moves from `missed` to
`mastered` only when a re-ask is answered correctly.

**Stopping.** The quiz ends when every concept in the inventory is `mastered` — that is
mastery, and nothing less ends the session. The exceptions: the user says stop, wrap
up, or that's enough, in which case generate the doc anyway with untested concepts
marked as such. Every five questions or so, mention progress ("4 concepts left, 2 of
them re-asks") so the user can see the end approaching.

Keep the tone collegial — a colleague helping them level up, not an examiner. When they
miss, the explanation is the payoff, not the penalty.

## Phase 4 — Generate the wiki doc

Write a single markdown file to `docs/wiki/<domain>.md` in the project (announce the
path; if the user wants it elsewhere, put it there). Use this structure:

```markdown
# <Domain> — Domain Wiki

> Generated by domain-tutor on <date>

## Overview

A narrative tour of the domain. Link each key term on first mention to its entry
below: [render profile](#render-profile).

## Concepts

### Render profile

What it is and why it exists. Depth scales with the quiz: concepts the user answered
correctly first time get two or three sentences; concepts they missed get the full
treatment — the explanation that finally landed during the quiz, expanded.

**Watch out:** (missed concepts only) the specific misconception from the quiz, stated
plainly, so future-them doesn't repeat it.

**References:** `src/main/java/.../RenderProfile.java:42` · Related:
[encoder pipeline](#encoder-pipeline)
```

Rules for the doc:

- Anchor links use GitHub-style slugs (lowercase, spaces → hyphens).
- Every entry's **References** line points at real files verified during research —
  this doc is only useful if the links hold up.
- Cross-link related concepts to each other; a wiki's value is in the connections.
- If the session ended early, list untested concepts under a final "Not yet covered"
  section so the user knows where the map has blank spots.

Finish by telling the user where the doc is and which concepts cost them a re-ask —
those are the ones worth revisiting in a week.
