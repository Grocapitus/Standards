# Grocapitus Organization Standards

This repository contains the canonical standards for all Claude Code work across the Grocapitus GitHub organization.

## What's Here

- **CLAUDE.md** — The behavioral principles every Claude session must follow. Based on Andrej Karpathy's framework with Grocapitus-specific guidance.
- **.github/workflows/claude-compliance.yml** — GitHub Actions workflow that validates every PR contains CLAUDE.md with required sections. Used as a reusable workflow across all repos.
- **.claude/settings.json** — Template settings file for Claude Code projects. Copy this to your repos.
- **setup-haiku-alias.sh** — Shell script that enforces Claude Haiku as the default model. Add to your devcontainer's postCreateCommand.

## For Developers

### Using These Standards

1. **Copy CLAUDE.md** into your repo
   ```bash
   curl -o CLAUDE.md https://raw.githubusercontent.com/grocapitus/standards/main/CLAUDE.md
   git add CLAUDE.md
   git commit -m "Add Grocapitus behavioral standards"
   git push
   ```

2. **Add the compliance workflow** to your repo
   ```bash
   mkdir -p .github/workflows
   cat > .github/workflows/standards.yml << 'EOF'
   name: Grocapitus Standards

   on:
     pull_request:
       branches: [main]

   jobs:
     claude-compliance:
       uses: grocapitus/standards/.github/workflows/claude-compliance.yml@main
   EOF
   git add .github/workflows/standards.yml
   git commit -m "Add Grocapitus compliance check"
   git push
   ```

3. **Set up Haiku model enforcement**
   ```bash
   bash <(curl https://raw.githubusercontent.com/grocapitus/standards/main/setup-haiku-alias.sh)
   ```
   Or add to your devcontainer's `postCreateCommand.sh`:
   ```bash
   bash <(curl https://raw.githubusercontent.com/grocapitus/standards/main/setup-haiku-alias.sh)
   ```

### The 4 Karpathy Principles

Every Claude Code session must follow these:

1. **Think Before Coding** — State assumptions, ask questions, understand context
2. **Simplicity First** — Minimum code, no speculation, no over-engineering
3. **Surgical Changes** — Focused commits, touch only what's needed
4. **Goal-Driven Execution** — Define success, test as you go, know when to stop

**Plus:** Model Policy — **You MUST use Claude Haiku. Sonnet is prohibited.**

## For Organization Admins

### Enforcing Across All Repos

See **SETUP_GUIDE.md** for step-by-step instructions to:
1. Set required status checks on all repos
2. Create the org `.github` repository with pull request template
3. Configure Anthropic Console to restrict Haiku (if on Team plan)

### The Enforcement Stack

| Layer | Method | Bypass Risk |
|---|---|---|
| CLAUDE.md existence | GitHub Actions ✅ | No — blocks merge |
| Karpathy principles | GitHub Actions grep | No — blocks merge |
| Haiku model policy | GitHub Actions grep | No — blocks merge |
| Haiku-only CLI | Shell alias | Medium — can override alias |
| Haiku reminder | SessionStart hook | Medium — just a reminder |
| Haiku restriction | Anthropic Console | None — hardest block |

## FAQ

**Q: Why Haiku and not Sonnet?**
A: Haiku is 5× cheaper per token, 50–100ms faster, and sufficient for 95% of tasks. It encourages thinking before coding (Sonnet tempts overthinking).

**Q: Can I use Sonnet for "complex" tasks?**
A: No. Haiku is the standard. If you hit a limit, rethink your approach to be simpler.

**Q: What if I really need Sonnet?**
A: Talk to Neal (admin). But the answer will be no. Haiku is enforced org-wide.

**Q: How do I know my PR passed the compliance check?**
A: Open a PR on any repo. You'll see `claude-compliance / Verify CLAUDE.md standards` in the checks. It must be green (✅) to merge.

**Q: I forgot to copy CLAUDE.md. Can I still work?**
A: You can work, but you can't merge. The CI check will fail. Copy CLAUDE.md from this repo and try again.

---

**Last Updated:** May 2026  
**Maintained by:** Neal Bawa, Grocapitus Admin
