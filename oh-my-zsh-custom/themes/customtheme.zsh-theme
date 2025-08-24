# vim:ft=zsh ts=2 sw=2 sts=2
#
# Agnoster ZSH Theme - Image Inspired + Git
# One line: time | separator | user | directory | git

### Segment drawing
CURRENT_BG='NONE'
SEGMENT_SEPARATOR="\ue0b0"

# --- Image-style palette (time + separator + user + dir) ---
IMG_TIME_BG="#3b4a5a"   # dark slate for time (swapped with user)
IMG_USER_BG="#0077b6"   # deep blue for user (swapped with time)
IMG_DIR_BG="#495867"     # slightly lighter blue-grey for directory
IMG_TEXT="#eaf6ff"       # soft near-white text
IMG_GRAD1="#00d4ff"      # cyan
IMG_GRAD2="#00bbf9"      # teal-cyan

# --- Original vibrant palette (for git + status) ---
CTP_BASE="#f5f0ff"
CTP_GREEN="#38b000"
CTP_PEACH="#ff7900"
CTP_SAPPHIRE="#00bbf9"
CTP_RED="#ff0054"

### Segment drawing functions
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"

  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    print -n "%{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
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
prompt_time() {
  prompt_segment $IMG_TIME_BG $IMG_TEXT "%D{%H:%M}"
}

prompt_separator() {
  prompt_segment $IMG_GRAD1 $IMG_TEXT ""
  prompt_segment $IMG_GRAD2 $IMG_TEXT ""
}

prompt_context() {
  prompt_segment $IMG_USER_BG $IMG_TEXT "%n"
}

prompt_dir() {
  prompt_segment $IMG_DIR_BG $IMG_TEXT "%~"
}

prompt_git() {
  local ref dirty git_status
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2>/dev/null) || ref="➦ $(git rev-parse --short HEAD 2>/dev/null)"
    git_status=$(git status --porcelain 2>/dev/null)

    local bgclr=$CTP_GREEN
    [[ -n $dirty ]] && bgclr=$CTP_PEACH
    [[ $(\grep -c "^.M" <<< "$git_status") -gt 0 ]] && bgclr=$CTP_SAPPHIRE
    [[ $(\grep -c "^.D" <<< "$git_status") -gt 0 ]] && bgclr=$CTP_RED

    prompt_segment $bgclr $CTP_BASE "${ref/refs\/heads\// }"
  fi
}

### Main prompt builder
build_prompt() {
  RETVAL=$?
  prompt_time
  prompt_separator
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '

### Git helper
parse_git_dirty() {
  local STATUS
  STATUS=$(git status --porcelain 2>/dev/null | tail -n1)
  [[ -n $STATUS ]] && echo "true"
}

