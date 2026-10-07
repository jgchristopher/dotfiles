function cyberduck-creds --description 'Export AWS SSO creds into a static <profile>-cyberduck profile for Cyberduck'
    set -l src $argv[1]
    if test -z "$src"
        echo "usage: cyberduck-creds <sso-profile>" >&2
        return 1
    end
    set -l dst "$src-cyberduck"

    aws sso login --profile $src; or return 1

    set -l j (aws configure export-credentials --profile $src | string collect); or return 1

    aws configure set aws_access_key_id (echo $j | jq -r .AccessKeyId) --profile $dst
    aws configure set aws_secret_access_key (echo $j | jq -r .SecretAccessKey) --profile $dst
    aws configure set aws_session_token (echo $j | jq -r .SessionToken) --profile $dst

    echo "Wrote profile '$dst' (expires "(echo $j | jq -r .Expiration)")"
end
