set -q jomik_git_branch_glyph
or set -g jomik_git_branch_glyph ""

set -q jomik_git_push_glyph
or set -g jomik_git_push_glyph "⇡"

set -q jomik_git_pull_glyph
or set -g jomik_git_pull_glyph "⇣"

function fish_right_prompt
  # If is in git dir
  if type -q git; and command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    # Branch name or revision hash
    set -l branch (git symbolic-ref --short HEAD ^/dev/null; or git show-ref --head -s --abbrev | head -n1 ^/dev/null)
    set_color blue
    echo -n "[$branch"
    
    command git diff-files --quiet --ignore-submodules ^/dev/null; or set -l has_unstaged_files
    command git diff-index --quiet --ignore-submodules --cached HEAD ^/dev/null; or set -l has_staged_files

    if set -q has_unstaged_files
      set_color red
      echo -ns " " $jomik_git_branch_glyph
    else if set -q has_staged_files
      set_color yellow
      echo -ns " " $jomik_git_branch_glyph
    end
    
    command git rev-parse --abbrev-ref '@{upstream}' >/dev/null ^&1; and set -l has_upstream
    if set -q has_upstream
      set -l commit_counts (command git rev-list --left-right --count 'HEAD...@{upstream}' ^/dev/null)
      
      set -l commits_to_push (echo $commit_counts | cut -f 1 ^/dev/null)
      set -l commits_to_pull (echo $commit_counts | cut -f 2 ^/dev/null)

      if test $commits_to_push -ne 0
        if test $commits_to_pull -ne 0
          set_color red
        else
          set_color yellow
        end
        echo -ns " " $jomik_git_push_glyph
      end

      if test $commits_to_pull -ne 0
        if test $commits_to_push -ne 0
          set_color red
        else
          set_color yellow
        end
        echo -ns " " $jomik_git_pull_glyph
      end
    end

    set_color blue
    echo -n "]"
    set_color normal
  end
end