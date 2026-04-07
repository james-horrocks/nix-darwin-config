{
  config,
  pkgs,
  lib,
  ...
}:

let
  mempalace-src = pkgs.fetchFromGitHub {
    owner = "milla-jovovich";
    repo = "mempalace";
    rev = "v3.0.0";
    sha256 = "sha256-V+hRylKf0okDmRh9lwkcf2uXpiqSYjABHm/9EQY0znc=";
  };
in
{
  # Install mempalace into a dedicated venv on activation
  home.activation.installMempalace = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/.claude/mcp-env" ]; then
      $DRY_RUN_CMD python3 -m venv "$HOME/.claude/mcp-env"
    fi
    $DRY_RUN_CMD "$HOME/.claude/mcp-env/bin/pip" install --quiet --upgrade mempalace
  '';

  # Hook scripts sourced from upstream
  home.file.".claude/mempalace-hooks/mempal_save_hook.sh" = {
    source = "${mempalace-src}/hooks/mempal_save_hook.sh";
    executable = true;
  };
  home.file.".claude/mempalace-hooks/mempal_precompact_hook.sh" = {
    source = "${mempalace-src}/hooks/mempal_precompact_hook.sh";
    executable = true;
  };

  # MCP server — gives Claude 19 mempalace_* tools (wake_up, search, save, etc.)
  programs.claude-code.mcpServers.mempalace = {
    type = "stdio";
    command = "${config.home.homeDirectory}/.claude/mcp-env/bin/python";
    args = [
      "-m"
      "mempalace.mcp_server"
    ];
  };
}
