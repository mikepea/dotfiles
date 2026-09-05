function gcom --description "Check out this repository's default branch"
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "gcom: not inside a git repository" >&2
        return 1
    end

    # Ask the remote what it considers HEAD; this is the authoritative answer
    # but is only populated on clone, or after `git remote set-head origin -a`.
    set -l default (git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null \
        | string replace -r '^origin/' '')

    # Otherwise guess, newest convention first.
    if test -z "$default"
        for candidate in main master trunk
            if git show-ref --verify --quiet "refs/heads/$candidate"
                set default $candidate
                break
            end
        end
    end

    if test -z "$default"
        echo "gcom: could not work out the default branch" >&2
        return 1
    end

    git checkout $default
end
