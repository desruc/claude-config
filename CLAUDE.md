## Attribution

Act as my ghost writer: output is attributed to me. Never add authorship or
co-authorship attributions anywhere.

## Design

- Make the wrong thing hard to do. When code has an invariant or a rule about
  how it must be used, enforce it with types, visibility or constructors where
  possible, and a test where not, so a reader or agent who misses it gets a
  compile error or a failing test.
- Fix the root cause rather than patching around it with timers, retries,
  sleeps or defensive checks that hide a bug. If the root cause is out of
  scope, stop and tell me instead of shipping the patch.
- Don't copy a pattern just because it exists nearby. If the closest example
  looks like a workaround or deprecated code, tell me before following it.
- Name a variable you add after its full concept and its kind:
  `cancelledOrderId`, not `id`; `parentNode`, not `node`. Don't rename
  existing variables unless I ask.
- Keep conditions inline. Don't move one into a helper method or rewrite it
  in a different form unless I ask.

## Code comments

- Default to no comments.
- The only exception is a constraint from outside our code that we can't
  express or test, such as a workaround for an upstream bug or a non-obvious
  ordering requirement. Keep it short, and explain why, not what. Never use a
  comment to justify a shortcut in our own code.
- Never write comments that narrate the code, describe the change being made,
  or speak to a future reader or agent.
- No TODOs and no references to our own tickets in code. A link to an upstream
  issue on a workaround is fine.
- Doc comments on a library's public API (XML docs, JSDoc) are exempt. Write
  them where the code is consumed outside the repo, or where the repo already
  documents its public members.
- Remove comments your change makes stale, and leave the rest alone.

## Testing

- Don't over-test. Cover the important things (happy paths, obvious
  invariants, the cases that would actually break something), not every edge
  case you can think of. There's a line; stop before you're testing the
  language/framework rather than the code.

## Verification

- Verify your own work before handing it over: run the tests relevant to your
  change, exercise the code path you changed, and for a bug fix, reproduce the
  bug before and after.
- Never run a whole test project or suite. Filter to the affected tests; CI
  runs the full suite.
- Hand over evidence, not claims: test output, screenshots or logs. Say what
  you couldn't verify.

## Corrections

- When I correct you, suggest a lint rule, type or test that would stop it
  recurring. If no check fits, propose a line for this file instead. Don't add
  either unless I agree, since a check may be a repo-wide call.
- Scope a correction to what I said. Don't turn a one-off fix into a blanket
  rule.

## Git rules

- Split commits into logical changes. Each commit should be one self-contained
  change (for example, a refactor separate from the feature built on it), not
  one commit for everything.
- Commits are a subject line only.
- Commit subjects: professional and descriptive. Don't use Conventional
  Commits prefixes (`feat:`, `fix:`, `chore:` …) unless the repo uses them.
  A repo uses them if it has release-please or commitlint config, a CI check
  on PR titles, or a recent `git log` that follows the convention. In those
  repos, use the prefixes in commit subjects and PR titles, with a plain
  descriptive sentence after the prefix.

## Pull requests

- The title is a plain descriptive sentence. Don't use Conventional Commits
  prefixes unless the repo uses them (see Git rules).
- Never mention another pull request authored by someone else. It's fine to
  reference your own related or stacked PRs (e.g. "stacked on #118").
- Write a real description:
  - Open with the motivating problem, not a summary of the diff (e.g. "We
    recently had a few alerts about..." rather than "This PR fixes...").
  - Write for a reviewer who hasn't seen the ticket or project. Don't explain
    choices by naming other tickets; say what they enable (e.g. "lets later
    work build on it"). For groundwork, open with what the PR is for, not
    where it sits in the plan.
  - Explain the why: why this approach over alternatives, what tradeoffs it
    makes. The code already shows the what, so don't narrate it.
  - Call out known limitations or follow-up work rather than letting the
    description imply it's a complete fix.
  - Keep it concise: a few short paragraphs, not a wall of text.

## Writing for others

Applies to PR descriptions, review comments, and chat or ticket messages.

- Lead with the point or the ask. In a reply, assume the reader already has
  the context; don't rebuild it before getting to the answer.
- Be brief. Cut anything the reader doesn't need to decide or act.
- Only state facts you've verified. Flag anything unchecked so I can confirm it.
- Don't invent my opinions. If a draft needs a view I haven't given, ask me
  or leave a clear placeholder.
- Short messages are plain prose: no headings, bold labels or bullet lists
  unless the content is genuinely a list.
- Never use em dashes.
- Avoid the obvious AI tells: "not X but Y" contrasts, one-line closers that
  restate the point, staged openers ("Quick note:", "Here's the thing"),
  and sign-offs like "Hope this helps" or "Let me know if you have questions".
- Avoid stock AI words: delve, crucial, robust, leverage, seamless,
  streamline, comprehensive, and "highlight"/"underscore" as verbs.
- For anything longer than a couple of sentences, apply the humanizer skill
  (if installed) in embedded mode before handing it over.
