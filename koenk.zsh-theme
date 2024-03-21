if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
local jobs="%(1j.%{%F{white}%}%j .)"

PROMPT='%{$fg_bold[$NCOLOR]%}%n%{$fg_bold[white]%}@%m%{$fg_bold[blue]%} %~ %{$reset_color%} \
$(git_prompt_info)${jobs}\
%{$fg_bold[red]%}%(!.#.»)%{$reset_color%} '
PROMPT2='%{$fg[red]%}\ %{$reset_color%}'
RPS1='${return_code}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}±%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="D"

