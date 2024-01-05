function addpaths
    if not contains -- $argv $fish_user_paths
        set -U fish_user_paths $fish_user_paths $argv
    end
end
