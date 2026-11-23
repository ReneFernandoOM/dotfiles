#!/bin/bash
# Reports Cursor agent state to Rex with the Program Status Protocol (OSC 7501).
# Usage: rex-status.sh working|stop

event="$1"

respond() {
  [ "$event" = "working" ] && echo '{"continue": true}' || echo '{}'
  exit 0
}

# Hooks run without a controlling terminal, so find the agent's tty among our ancestors.
find_agent() {
  local pid=$$ tty
  while [ "${pid:-1}" -gt 1 ]; do
    tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
    if [ -n "$tty" ] && [ "$tty" != "??" ]; then
      echo "$pid /dev/$tty"
      return 0
    fi
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
  done
  return 1
}

if [ "$event" = "watch" ]; then
  agent_pid="$2" tty="$3" token="$4"
else
  input=$(cat)
  [ -n "$REX_BLOCK" ] || respond
  read -r agent_pid tty < <(find_agent) || respond
  [ -w "$tty" ] || respond
fi

pidfile="${TMPDIR:-/tmp}/rex-cursor-status-${tty##*/}.pid"
rex="${REX_BIN_DIR:+$REX_BIN_DIR/}rex"

report() {
  local pairs="state=$1:app=cursor"
  [ -n "$2" ] && pairs="$pairs:kind=$2"
  [ -n "$3" ] && pairs="$pairs:msg=$(printf '%s' "$3" | base64 | tr -d '\n')"
  printf '\033]7501;%s\033\\' "$pairs" >"$tty" 2>/dev/null
}

stop_watcher() {
  local pid token
  [ -f "$pidfile" ] && read -r pid token <"$pidfile" && kill "$pid" 2>/dev/null
  rm -f "$pidfile"
}

watcher_current() {
  local pid token
  read -r pid token <"$pidfile" 2>/dev/null && [ "$token" = "$1" ]
}

# The CLI has no hook for its question prompt, so watch the bottom of the screen for it.
watch_questions() {
  local blocked="" screen question
  sleep 0.5
  while kill -0 "$agent_pid" 2>/dev/null && watcher_current "$token"; do
    screen=$("$rex" capture -s "$REX_SESSION" -b "$REX_BLOCK" --trim 2>/dev/null | tail -n 40)
    if printf '%s\n' "$screen" | tail -n 15 | grep -q 'Enter next/submit'; then
      question=$(printf '%s\n' "$screen" | grep -E '^[[:space:]]*│[[:space:]]*[0-9]+\. ' | tail -n 1 |
        sed -E 's/^[[:space:]]*│[[:space:]]*[0-9]+\. //; s/[[:space:]]*│[[:space:]]*$//' |
        LC_ALL=C tr -d '[:cntrl:]' | LC_ALL=en_US.UTF-8 cut -c1-180)
      if [ "$blocked" != "${question:-?}" ]; then
        report blocked question "${question:-Waiting for an answer}"
        blocked="${question:-?}"
      fi
    elif [ -n "$blocked" ]; then
      report working
      blocked=""
    fi
    sleep 1
  done
}

case "$event" in
  watch)
    watch_questions
    exit 0
    ;;
  working)
    stop_watcher
    report working
    token="$$.$RANDOM"
    # The CLI kills the hook's process group on exit, so the watcher needs its own session.
    /usr/bin/perl -MPOSIX -e 'POSIX::setsid(); exec @ARGV' -- "$0" watch "$agent_pid" "$tty" "$token" \
      </dev/null >/dev/null 2>&1 &
    echo "$! $token" >"$pidfile"
    ;;
  stop)
    stop_watcher
    case "$input" in
      *'"status":"aborted"'* | *'"status": "aborted"'*) report idle ;;
      *'"status":"error"'* | *'"status": "error"'*) report error ;;
      *) report done ;;
    esac
    ;;
esac

respond
