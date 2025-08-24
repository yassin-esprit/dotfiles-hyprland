# vim:ft=zsh ts=2 sw=2 sts=2
#
# Agnoster ZSH Theme - Electric Saturated Edition
# With glowing purple time segment
# + Root-aware theme (red heavy)

### Segment drawing
CURRENT_BG='NONE'

# Powerline symbols
SEGMENT_SEPARATOR="\ue0b0"
BRANCH="\ue0a0"
CROSS="\u2718"
LIGHTNING="\u26a1"
GEAR="\u2699"

# Ultra-Saturated Color Palette
CTP_BASE="#f5f0ff"       # Bright cream base
CTP_TEXT="#3a0ca3"       # Deep royal purple text
CTP_SURFACE0="#d9d6ff"   # Lavender mist background

# Vibrant Accent Colors
CTP_ELECTRIC_PURPLE="#c721ff"  # Time segment
CTP_MAUVE="#9d4edd"
CTP_LAVENDER="#7b2cbf"
CTP_SAPPHIRE="#00bbf9"
CTP_SKY="#00d4ff"
CTP_TEAL="#00f5d4"
CTP_GREEN="#38b000"
CTP_YELLOW="#ffd000"
CTP_PEACH="#ff7900"
CTP_RED="#ff0054"
CTP_PINK="#ff36ab"

# --- ROOT THEME (extra red) ---
CTP_ROOT_BG="#8b0000"   # Darker red for backgrounds
CTP_ROOT_FG="#ffffff"   # White text on root segments

### Segment drawing functions
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"

  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    print -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    print -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && print -n $3
}

prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    print -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    print -n "%{%k%}"
  fi
  print -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
prompt_context() {
  if [[ $UID -eq 0 ]]; then
    # Root → red heavy
    prompt_segment $CTP_ROOT_BG $CTP_ROOT_FG "%n@%m"
  elif [[ -n "$SSH_CLIENT" ]]; then
    prompt_segment $CTP_MAUVE $CTP_BASE "%n@%m"
  else
    prompt_segment $CTP_LAVENDER $CTP_BASE "%n@%m"
  fi
}

prompt_git() {
  local PL_BRANCH_CHAR="$BRANCH"
  local ref dirty mode repo_path
  local modified untracked added deleted
  local bgclr fgclr=$CTP_BASE

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"

    if [[ -n $dirty ]]; then
      bgclr=$CTP_PEACH
    else
      bgclr=$CTP_TEAL
    fi

    git_status=$(git status --porcelain 2> /dev/null)
    [[ $(\grep -c "^??" <<< "${git_status}") -gt 0 ]] && untracked=" ✦"
    [[ $(\grep -c "^A" <<< "${git_status}") -gt 0 ]] && added=" ➕"
    [[ $(\grep -c "^.M" <<< "${git_status}") -gt 0 ]] && modified=" ✎" && bgclr=$CTP_SAPPHIRE
    [[ $(\grep -c "^.D" <<< "${git_status}") -gt 0 ]] && deleted=" ✖" && bgclr=$CTP_RED

    prompt_segment $bgclr $fgclr
    print -n "%{$fg_bold[$fgclr]%}${ref/refs\/heads\//$PL_BRANCH_CHAR }${modified}${deleted}${added}${untracked}"
  fi
}

prompt_dir() {
  if [[ $UID -eq 0 ]]; then
    prompt_segment $CTP_RED $CTP_BASE "%~"
  else
    prompt_segment $CTP_SKY $CTP_TEXT "%~"
  fi
}

prompt_virtualenv() {
  if [[ -n $VIRTUAL_ENV ]]; then
    prompt_segment $CTP_GREEN $CTP_BASE "(%{$fg_bold[$CTP_BASE]%}`basename $VIRTUAL_ENV`%)"
  fi
}

prompt_time() {
  prompt_segment $CTP_ELECTRIC_PURPLE $CTP_BASE "%D{%a %d %b %H:%M}"
}

prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{$CTP_RED}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{$CTP_YELLOW}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{$CTP_SKY}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment $CTP_SURFACE0 $CTP_TEXT "$symbols"
}

### Main prompt builder
build_prompt() {
  RETVAL=$?
  print -n "\n"
  prompt_status
  prompt_time
  prompt_virtualenv
  prompt_dir
  prompt_git
  prompt_end
  CURRENT_BG='NONE'
  print -n "\n"
  prompt_context
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '

### Git helper
parse_git_dirty() {
  local STATUS
  STATUS=$(git status --porcelain 2> /dev/null | tail -n1)
  [[ -n $STATUS ]] && echo "true"
}

