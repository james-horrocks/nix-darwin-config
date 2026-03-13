{ config, pkgs, lib, username, ... }:

{
  home.file.".claude/statusline-command.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Read JSON input (Claude Code typically pipes JSON on stdin).
      # If stdin is a TTY (or otherwise not piped), don't block waiting for input.
      input=""
      if [ ! -t 0 ]; then
          input=$(cat)
      fi

      # Extract workspace info
      cwd=""
      if [ -n "$input" ] && command -v jq >/dev/null 2>&1; then
          cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty' 2>/dev/null)
      fi

      # Fall back to the current working directory if input is missing/unparseable.
      if [ -z "$cwd" ] || [ "$cwd" = "null" ]; then
          cwd="$PWD"
      fi

      # Get short path (replacing home with ~)
      short_path="''${cwd/#$HOME/~}"

      # Get git branch if in a git repo
      git_info=""
      if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
          branch=$(git -C "$cwd" -c "core.fileMode=false" -c "gc.auto=0" branch --show-current 2>/dev/null)
          if [ -n "$branch" ]; then
              # Get git status
              if ! git -C "$cwd" -c "core.fileMode=false" -c "gc.auto=0" diff --quiet 2>/dev/null; then
                  changes=" *"
              else
                  changes=""
              fi
              git_info=$(printf "\033[48;5;150m\033[38;5;233m  $branch$changes \033[0m")
          fi
      fi

      # Get Python virtual environment if active
      python_info=""
      if [ -n "$VIRTUAL_ENV" ]; then
          venv_name=$(basename "$VIRTUAL_ENV")
          python_version=$(python --version 2>&1 | cut -d' ' -f2)
          python_info=$(printf "\033[48;5;24m\033[38;5;229m  $venv_name $python_version \033[0m")
      fi

      # Build the status line
      printf "\033[48;5;33m\033[38;5;233m $short_path \033[0m"
      [ -n "$git_info" ] && printf "$git_info"
      [ -n "$python_info" ] && printf "$python_info"
      printf "\n"
    '';
  };

  programs.claude-code = {
    enable = true;

    mcpServers = {
      miro = {
        type = "http";
        url = "https://mcp.miro.com";
      };
    };

    settings = {
      hooks = {
        Stop = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "osascript -e 'tell application \"System Events\"' -e '  set frontApp to name of first application process whose frontmost is true' -e 'end tell' -e 'if frontApp is not \"Terminal\" then' -e '  display notification \"Claude is ready\" with title \"Claude Code\" sound name \"Glass\"' -e 'end if'";
              }
            ];
          }
        ];
        Notification = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "osascript -e 'tell application \"System Events\"' -e '  set frontApp to name of first application process whose frontmost is true' -e 'end tell' -e 'if frontApp is not \"Terminal\" then' -e '  display notification \"Claude is waiting for input\" with title \"Claude Code\" sound name \"Ping\"' -e 'end if'";
              }
            ];
          }
        ];
      };

      statusLine = {
        type = "command";
        command = "~/.claude/statusline-command.sh";
      };

      enabledPlugins = {
        "context7@claude-plugins-official" = true;
        "github@claude-plugins-official" = true;
        "code-simplifier@claude-plugins-official" = true;
        "superpowers@claude-plugins-official" = true;
        "security-guidance@claude-plugins-official" = true;
        "claude-md-management@claude-plugins-official" = true;
        "atlassian@claude-plugins-official" = true;
        "claude-code-setup@claude-plugins-official" = true;
        "context-mode@context-mode" = true;
      };

      permissions = {
        allow = [
          "mcp__plugin_context7_context7__resolve-library-id"
          "mcp__plugin_context7_context7__query-docs"
          "mcp__plugin_github_github__get_me"
          "mcp__plugin_github_github__list_issues"
          "mcp__plugin_github_github__list_pull_requests"
          "mcp__plugin_github_github__list_commits"
          "mcp__plugin_github_github__list_branches"
          "mcp__plugin_github_github__pull_request_read"
          "mcp__plugin_github_github__search_repositories"
          "mcp__plugin_github_github__get_file_contents"
          "mcp__plugin_atlassian_atlassian__search"
          "mcp__plugin_atlassian_atlassian__searchConfluenceUsingCql"
          "mcp__plugin_atlassian_atlassian__getAccessibleAtlassianResources"
          "mcp__plugin_atlassian_atlassian__getConfluencePage"
          "mcp__plugin_atlassian_atlassian__getConfluencePageDescendants"
          "mcp__plugin_atlassian_atlassian__getJiraIssue"
          "mcp__plugin_context-mode_context-mode__ctx_execute"
          "mcp__plugin_context-mode_context-mode__ctx_execute_file"
          "mcp__plugin_context-mode_context-mode__ctx_search"
          "mcp__plugin_context-mode_context-mode__ctx_batch_execute"
          "Bash(echo:*)"
          "Bash(find:*)"
          "Bash(head:*)"
          "Bash(tail:*)"
          "Bash(grep:*)"
          "Bash(ls:*)"
          "Bash(cat:*)"
          "Bash(awk:*)"
          "Bash(md5:*)"
          "Bash(git -C * log:*)"
          "Bash(gh repo view:*)"
          "Bash(gh api *)"
          "Bash(gh pr list *)"
          "Bash(gh pr view:*)"
        ];
        ask = [
          "Bash(gh api --X *)"
        ];
      };
    };
  };
}
