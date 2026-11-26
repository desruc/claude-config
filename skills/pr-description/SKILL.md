---
name: pr-description
description: Write or edit a pull request's title and description. Use before running `gh pr create` or `gh pr edit` with a title or body, and whenever drafting pull request text for a reviewer.
---

# Pull request descriptions

A description tells a reviewer why this code is landing. The diff already shows what changed, so the description sets the scene, gives the reason, and stops.

## Title

A Conventional Commits type followed by a plain descriptive sentence, such as `fix(auth): reject expired tokens`. Leave the type off if the repo sets `claude.conventionalPrTitles` to false in its git config.

## Shape

Write plain prose in this order:

1. **Background.** The situation a reviewer needs before the change makes sense: the bug, the issue, or the bigger piece of work this belongs to. Write for someone who hasn't seen the ticket. Describe what broke and who it affected, not the mechanics of how the code got there.
2. **What this PR does and why.** Open with "This PR..." and sum up the change in a sentence or two, then say why it's landing. When a PR makes several changes, name what they add up to. Listing them one by one walks through the diff. Mention a design decision only where a reviewer would otherwise ask about it, and give the reason in a clause.
3. **Limitations or follow-up.** What this doesn't cover, so the description doesn't imply a complete fix. Leave it out when there's nothing to say.

A larger change gets two or three short paragraphs. A small one can be a sentence of background and a sentence of what the PR does.

If the repo has a pull request template, fill in its sections in this style.

## Sentences and paragraphs

Write it the way you'd explain the change to a teammate. A sentence makes one point, and that point can carry its reason or its consequence. Words like "so", "because" and "but" link one sentence to the next, and they're what make the text flow. Avoid sentences that string several separate facts together with commas, because readers skim past them.

Start a new paragraph when the subject changes. Most paragraphs are two to four sentences, and a limitation can sit on its own in one. A paragraph longer than that is usually covering two subjects.

Too dense:

> A filled title comes from a commit subject, and since commit subjects here are plain sentences with no type prefix, the PR ended up with a non-Conventional title that becomes the commit on a squash merge.

Too choppy:

> A filled title comes from the commit subject. Commit subjects here have no type prefix. The title becomes the commit on a squash merge.

Better:

> A filled title is copied from the commit subject, and commit subjects here have no type prefix. On a squash merge, that title becomes the commit on main.

## Examples

> Admins change notification settings by editing a YAML file and restarting the service. Support gets a few tickets a month from people who edited the wrong file or forgot the restart, and it's the main thing stopping us from letting team leads manage their own notifications.
>
> This PR adds a notification settings page that reads and writes those settings through the existing settings API, so changes apply without a restart. The YAML file still works and takes precedence when it's set, which keeps current deployments behaving the same.
>
> Only admins can see the page for now. Opening it to team leads needs the permission changes in a follow-up PR.

The first paragraph is only background, and by the end of it a reviewer knows why the work matters. The second describes the page by what it does for admins, without files or commits. The one decision a reviewer would question, keeping the YAML file, gets its reason in a clause. The sentences connect and vary in length, so nothing is packed in and nothing is chopped into fragments.

> The install steps in the README only worked on a machine that already had Claude Code set up, and running them a second time left stray links inside this repo.
>
> This PR reorders the steps and makes each one safe to rerun, so the same commands work on a new laptop and when pulling in changes.

A small fix still opens with the background, but it fits in two sentences. It says what went wrong for the person running the install, and leaves how `ln` and `mkdir` caused it to the diff.

## Leave out

- Commit-by-commit or change-by-change walkthroughs, file lists and implementation detail. The reviewer reads the diff for those.
- Headings, bold labels and bullet lists, unless the content is genuinely a list.
- Ticket numbers as explanations, and where the PR sits in a plan. Say what the work enables instead ("lets the settings page build on it").
- Pull requests someone else authored. My own related or stacked PRs are fine ("stacked on #118").
- Em dashes, "not X but Y" contrasts, staged openers ("Quick note:") and closing lines that restate the point.

## Facts and opinions

Only state facts you've verified, such as the cause of a bug or how often it happens. If the background needs something you haven't checked, or a view I haven't given, leave a clear placeholder like `[how many tickets a month?]` and tell me.

Before handing the description over, apply the humanizer skill (if installed) in embedded mode.
