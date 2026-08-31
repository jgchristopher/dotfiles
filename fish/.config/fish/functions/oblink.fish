function oblink -d 'Turn [[wikilinks]] into clickable OSC 8 hyperlinks that open in Obsidian'
    # Usage:
    #   cat note.md | oblink                  # filter stdin, default vault
    #   cat note.md | oblink -v Personal      # filter stdin, another vault
    #   oblink 'Projects/Issue Runner System' # print one link for a note path
    #
    # Ghostty cannot linkify [[...]] on its own: `link = <regex>` is
    # error.NotImplemented as of 1.3.1, and obsidian:// is absent from its
    # built-in URL scheme allowlist. OSC 8 is the only route, and it works
    # because tmux already advertises xterm-ghostty:hyperlinks.

    set -l vault jcOS
    set -l notes

    while set -q argv[1]
        switch $argv[1]
            case -v --vault
                set vault $argv[2]
                set -e argv[1..2]
            case '*'
                set -a notes $argv[1]
                set -e argv[1]
        end
    end

    if set -q notes[1]
        for note in $notes
            printf '%s\n' "[[$note]]"
        end | OB_VAULT=$vault _oblink_filter
    else
        OB_VAULT=$vault _oblink_filter
    end
end

function _oblink_filter -d 'stdin filter used by oblink'
    perl -pe '
      s{\[\[([^\]\|#]+)([^\]]*)\]\]}{
        my ($note, $rest) = ($1, $2);
        my $label = $rest =~ /\|(.+)/ ? $1 : $note;
        (my $enc = $note) =~ s/([^A-Za-z0-9_.~\/-])/sprintf("%%%02X", ord($1))/ge;
        "\e]8;;obsidian://open?vault=$ENV{OB_VAULT}&file=$enc\a[[$label]]\e]8;;\a"
      }ge'
end
