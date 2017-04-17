set -q jomik_prompt_arrow_glyph
or set -g jomik_prompt_arrow_glyph ""

set -q jomik_project_root_glyph
or set -g jomik_project_root_glyph "⊤"

set -q jomik_git_branch_glyph
or set -g jomik_git_branch_glyph ""

function __jomik_prompt_segment
  set_color $argv[1]
  echo -ns "[" $argv[2..-1] "]"
  set_color normal
end

function __jomik_path_to_prompt_fit
    set -q fish_prompt_pwd_dir_length
    or set -l fish_prompt_pwd_dir_length 1


    set realhome ~
    set -l tmp (string replace -r '^'"$realhome"'($|/)' '~$1' $argv[1])

    if [ $fish_prompt_pwd_dir_length -eq 0 ]
        echo $tmp
    else
        string replace -ar '(\.?[^/]{'"$fish_prompt_pwd_dir_length"'})[^/]*/' '$1/' $tmp
    end
end


function __jomik_git_branch_name
  echo (command git branch ^/dev/null | sed -n '/\* /s///p')
end

function __jomik_git_root
  echo (command git rev-parse --show-toplevel ^/dev/null)
end

function __jomik_git_project_name
  echo (command basename (__jomik_git_root))
end

function __jomik_git_relative_path
  set -l rel (command realpath --relative-to=(__jomik_git_root) $PWD)
  if test "$rel" != "."
    echo -ns "/" $rel
  end
end

function __jomik_prompt_git
  set -l git_branch (__jomik_git_branch_name)
  if test $git_branch
    set -l proj_name (__jomik_git_project_name)
    __jomik_prompt_segment blue $proj_name " " $jomik_git_branch_glyph " " $git_branch
  end
end

function __jomik_prompt_dir
  if test (__jomik_git_branch_name)
    set -l rel_path (__jomik_git_relative_path)
    __jomik_prompt_segment cyan $jomik_project_root_glyph (__jomik_path_to_prompt_fit $rel_path)
  else
    __jomik_prompt_segment cyan (prompt_pwd)
  end
end

function __jomik_prompt_error
  if test "$last_status" -ne 0
    __jomik_prompt_segment red $last_status
  end
end

function __jomik_prompt_arrow
  echo -ns $jomik_prompt_arrow_glyph " "
end

function __jomik_prompt_status_line
  type -q git; and __jomik_prompt_git
end

function fish_prompt
  set -g last_status $status

  set -l status_line (__jomik_prompt_status_line)
  if test $status_line
    echo $status_line
  end

  __jomik_prompt_dir
  __jomik_prompt_error
  __jomik_prompt_arrow
end
