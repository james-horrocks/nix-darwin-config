{
  config,
  pkgs,
  lib,
  username,
  ...
}:

let
  claude-code-statusline = pkgs.fetchFromGitHub {
    owner = "rz1989s";
    repo = "claude-code-statusline";
    rev = "65193de49080b97d8831732f81005387203f6139";
    sha256 = "1z9c973hcgwpjssmh22bakxy917b0f11azq6jcm184zspsinsnyy";
  };
in
{
  home.activation.claudeMarketplaces = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    marketplace_file="$HOME/.claude/plugins/known_marketplaces.json"
    mkdir -p "$(dirname "$marketplace_file")"
    [ -f "$marketplace_file" ] || echo '{}' > "$marketplace_file"

    if ! ${pkgs.jq}/bin/jq -e '."caveman"' "$marketplace_file" > /dev/null 2>&1; then
      ${pkgs.jq}/bin/jq '. + {
        "caveman": {
          "source": { "source": "github", "repo": "JuliusBrussee/caveman" },
          "installLocation": ($home + "/.claude/plugins/marketplaces/caveman"),
          "lastUpdated": "1970-01-01T00:00:00.000Z"
        }
      }' --arg home "$HOME" "$marketplace_file" > "$marketplace_file.tmp" \
        && mv "$marketplace_file.tmp" "$marketplace_file"
    fi
  '';

  home.file.".local/share/claude-code-statusline/statusline.sh" = {
    source = "${claude-code-statusline}/statusline.sh";
    executable = true;
  };
  home.file.".local/share/claude-code-statusline/lib" = {
    source = "${claude-code-statusline}/lib";
    recursive = true;
  };
  home.file.".claude/statusline/plugins/caveman/plugin.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      collect_caveman_data() { return 0; }
      render_caveman() {
        local caveman_flag="$HOME/.claude/.caveman-active"
        [ -f "$caveman_flag" ] || return 0
        local caveman_mode
        caveman_mode=$(cat "$caveman_flag" 2>/dev/null)
        if [ "$caveman_mode" = "full" ] || [ -z "$caveman_mode" ]; then
          printf '\033[38;5;172m[CAVEMAN]\033[0m'
        else
          local caveman_suffix
          caveman_suffix=$(echo "$caveman_mode" | tr '[:lower:]' '[:upper:]')
          printf '\033[38;5;172m[CAVEMAN:%s]\033[0m' "$caveman_suffix"
        fi
      }
      # Also provide get_caveman_component for legacy plugin system
      get_caveman_component() { render_caveman; }
      # Register with component system if available
      if type register_component &>/dev/null; then
        register_component "caveman" "Shows active caveman mode" "" "true"
      fi
    '';
  };
  home.file.".config/caveman/config.json".text = ''
    { "defaultMode": "lite" }
  '';
  home.file.".claude/statusline/plugins/caveman/plugin.toml".text = ''
    [plugin]
    name = "caveman"
    version = "1.0.0"
    description = "Shows active caveman mode in statusline"
  '';
  home.file.".claude/statusline/Config.toml".source = ./statusline-config.toml;
  home.file."bin/claude_api_key_helper.sh" = {
    text = ''
      #!/bin/bash
      op --account skyscanner.1password.eu read "op://Employee/Portkey - Claude Code API Key/credential"
    '';
    executable = true;
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
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "~/.claude/mempalace-hooks/mempal_save_hook.sh";
                timeout = 30;
              }
            ];
          }
        ];
        PreCompact = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "~/.claude/mempalace-hooks/mempal_precompact_hook.sh";
                timeout = 30;
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
        command = "CONFIG_PLUGINS_ENABLED=true CONFIG_PLUGINS_REQUIRE_SIGNATURE=false ~/.local/share/claude-code-statusline/statusline.sh";
        padding = 0;
      };

      apiKeyHelper = "~/bin/claude_api_key_helper.sh";
      env = {
        CLAUDE_CODE_MAX_OUTPUT_TOKENS = "8192";
        DISABLE_AUTOUPDATER = "1";
        ANTHROPIC_BASE_URL = "https://modelops-gateway.cellsdev-1.skyscannerplatform.net";
        ANTHROPIC_CUSTOM_HEADERS = "x-portkey-config: pc-claude-6c0482";
        DATABRICKS_HOST = "https://skyscanner-dev.cloud.databricks.com";
        DATABRICKS_CONFIG_PROFILE = "default";
        DATABRICKS_WAREHOUSE_ID = "d5f01b26a308cf40";
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
        "slack@claude-plugins-official" = true;
        "commit-commands@claude-plugins-official" = true;
        "context-mode@context-mode" = true;
        "sonarqube-mcp-analysis@skyscanner-claude-plugins" = true;
        "caveman@caveman" = true;
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
          "Bash(${pkgs.gh}/bin/gh repo view:*)"
          "Bash(${pkgs.gh}/bin/gh api:*)"
          "Bash(${pkgs.gh}/bin/gh pr list *)"
          "Bash(${pkgs.gh}/bin/gh pr view:*)"
          "mcp__miro__context_explore"
          "mcp__miro__board_list_items"
          "mcp__miro__context_get"
          "mcp__data-knowledge-base__list_domains"
          "mcp__data-knowledge-base__get_document"
          "mcp__databricks-utils__list_catalogs"
          "mcp__databricks-utils__get_table"
          "Bash(databricks jobs get-run:*)"
          "Bash(databricks jobs get-run-output:*)"
          "Bash(databricks runs get:*)"
          "Bash(java -version)"
          "Bash(python -m pytest:*)"
          "Bash(uv run pytest:*)"
        ];
        ask = [
          "Bash(gh api --X *)"
          "Bash(${pkgs.gh}/bin/gh api --X *)"
        ];
      };
    };
  };
}
