set -q jomik_prompt_arrow_glyph
or set -g jomik_prompt_arrow_glyph "➤"

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

function __jomik_in_git_dir
    if type -q git
        command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    else
        return 1
    end
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
        echo -s "/" $rel
    end
end

function __jomik_prompt_dir
    if __jomik_in_git_dir
        set -l rel_path (__jomik_git_relative_path)
        set -l proj_name (__jomik_git_project_name)
        __jomik_prompt_segment cyan $proj_name (__jomik_path_to_prompt_fit $rel_path)
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

function fish_prompt
    set -g last_status $status

    __jomik_prompt_dir
    __jomik_prompt_error
    __jomik_prompt_arrow
end
