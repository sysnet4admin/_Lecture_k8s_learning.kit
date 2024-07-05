#!/bin/bash  # Assuming the script needs to be executed by the shell

set -eou pipefail  # Set error handling options

IFS=$'\n\t'

SELF_CMD="$0"
exit_oky() { exit 0; }
exit_err() { exit 1; }

prerequisite_check() {
  if ! hash ollama >/dev/null 2>&1; then echo "ollama is not installed"; exit_err; fi
  if ! hash k8sgpt >/dev/null 2>&1; then echo "k8sgpt is not installed"; exit_err; fi
  if ! hash fzf >/dev/null 2>&1; then echo "fzf is not installed"; exit_err; fi
}

repeat(){
	for i in {1..50}; do echo -n "$1"; done
	echo ""
}

get_ollama_list() {
  ollama list | sed 's/|/ /' | awk 'NR >=2 {print $1}'
}

init_both() {
  k8sgpt cache remove                   >/dev/null 2>&1
  k8sgpt auth remove --backends localai >/dev/null 2>&1 || true # skip error msg || ignoring error 
  kill %1                               >/dev/null 2>&1 || true # skip error msg || ignoring error & kill previous localai 
}

run_ollama_n_auth_add_4_k8sgpt() {
  get_ollama_list
  local CHOICE
  CHOICE="$(FZF_DEFAULT_COMMAND="${SELF_CMD}" fzf --ansi --no-preview || true)"

  # Prepare to run  
  if [[ -z "${CHOICE}" ]]; then
    echo 2>&1 "Error: You need to choose specific model"
    exit_err
  else
    repeat '-'
    echo "Run this '${CHOICE}' to analyze for '`kubectl config current-context`'"
    repeat '='
    # Run the model as background 
    ollama run ${CHOICE} &
    # Auth add localai that already chose by above
    k8sgpt auth add --backend localai --baseurl http://localhost:11434/v1 --model ${CHOICE}
  fi
}

analyze_by_k8sgpt() {
  # Analyze k8s cluster by k8sgpt 
  if [[ "$#" -eq 0 ]]; then
    # Default
    k8sgpt analyze --backend localai --explain  
  elif [[ "$#" -eq 1 ]]; then
    echo "Run in '${1}' language"
    # Specific language  
    k8sgpt analyze --backend localai --explain --language "${1}"
  elif [[ "$#" -eq 2 ]] && [[ "$2" = "-i" ]]; then
    # Interactive mode 
    k8sgpt analyze --backend localai --explain --language "${1}" --interactive
  else 
    echo 2>&1 "Error: You need to choose specific option(s)"
    exit_err  
  fi 
}

main() {
  prerequisite_check
  init_both 
  run_ollama_n_auth_add_4_k8sgpt
  analyze_by_k8sgpt "$@"
}

main "$@"  # Run with all arguments 

