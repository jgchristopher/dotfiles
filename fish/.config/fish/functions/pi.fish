function pi --description 'Launch pi: prefer Bedrock (AWS profile), else fall back to Anthropic account'
    # Bedrock target. Provider/model defaults live in ~/.pi/agent/settings.json,
    # so the Bedrock branch passes no --provider/--model flags.
    set -l aws_profile PlatformDev
    set -l aws_region us-east-1

    # Anthropic fallback. Leave model empty to use pi's default Anthropic model.
    set -l fallback_provider anthropic
    set -l fallback_model ""

    # Probe whether the AWS profile has usable credentials (fails fast if the
    # SSO session is expired or the profile is missing).
    if aws sts get-caller-identity --profile $aws_profile --output text >/dev/null 2>&1
        env AWS_PROFILE=$aws_profile AWS_REGION=$aws_region command pi $argv
        return
    end

    # Credentials unavailable: offer to refresh the SSO session.
    read -l -P "pi: AWS profile '$aws_profile' unavailable. Refresh SSO login? [y/N] " answer
    if string match -qir '^y(es)?$' -- $answer
        if aws sso login --profile $aws_profile
            env AWS_PROFILE=$aws_profile AWS_REGION=$aws_region command pi $argv
            return
        end
        echo "pi: SSO login failed — falling back to $fallback_provider" >&2
    end

    echo "pi: using $fallback_provider (run /login if prompted)" >&2
    if test -n "$fallback_model"
        command pi --provider $fallback_provider --model $fallback_model $argv
    else
        command pi --provider $fallback_provider $argv
    end
end
