# Updated 2026-07-22: `claude` defaults to the Anthropic account.
# Opt into Bedrock per-launch with `--use bedrock` (or `--use=bedrock`).
# `--use anthropic` is accepted explicitly too. The flag is stripped before
# the real binary runs.
#
# Each branch builds the child environment explicitly with `env`, so the
# choice is deterministic even if the parent shell already exports Bedrock
# vars: the anthropic branch strips them with `env -u`, the bedrock branch
# sets them fresh. Nothing leaks into the parent shell either way.
function claude --description 'Run Claude Code; `--use bedrock` routes through Bedrock (PlatformDev)'
    set -l backend anthropic
    set -l forward

    set -l i 1
    while test $i -le (count $argv)
        set -l arg $argv[$i]
        switch $arg
            case '--use'
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set backend $argv[$i]
                else
                    echo "claude: --use needs a value (bedrock|anthropic)" >&2
                    return 2
                end
            case '--use=*'
                set backend (string replace -- '--use=' '' $arg)
            case '*'
                set -a forward $arg
        end
        set i (math $i + 1)
    end

    switch $backend
        case bedrock
            if command -q aws
                if not aws sts get-caller-identity --profile PlatformDev >/dev/null 2>&1
                    aws sso login --profile PlatformDev; or return $status
                end
            end
            env CLAUDE_CODE_USE_BEDROCK=1 \
                CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 \
                CLAUDE_CODE_ENABLE_AUTO_MODE=1 \
                AWS_PROFILE=PlatformDev \
                AWS_REGION=us-east-1 \
                command claude $forward
        case anthropic
            # Strip any inherited Bedrock env so this is truly the Anthropic path.
            env -u CLAUDE_CODE_USE_BEDROCK \
                -u AWS_PROFILE \
                -u AWS_REGION \
                command claude $forward
        case '*'
            echo "claude: unknown backend '$backend' (use bedrock|anthropic)" >&2
            return 2
    end
end
