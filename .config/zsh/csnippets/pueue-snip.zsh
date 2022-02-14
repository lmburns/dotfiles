format_lines() {
  lines="${1}" ;
  delimiter="${2}" ;
  formatter="${3}" ;
  line_count="$(printf "%s\n" "${lines}" | wc -l)" ;
  counter=1 ;
  accumulator="" ;
  printf "%s\n" "${lines}" | while read -r line ; do
    accumulator="${accumulator:+${accumulator}${delimiter}}$($formatter "${line}")" ;
    if test "${counter}" -eq "${line_count}" ; then
      printf "%s" "${accumulator}" ;
    else
      counter=$((counter + 1)) ;
    fi ;
  done ;
}

identity() {
  printf "%s" "${1}" ;
}

pw() {
  format_ids() {
    printf "%s" "${1%%,*}" ;
  }

  print_ids() {
    format_lines "${1}" " " format_ids ;
  }

  format_jq_properties_output() {
    printf "'\\(.%s)'" "${1}" ;
  }

  generate_jq_properties_output() {
    format_lines "${1}" "," format_jq_properties_output ;
  }

  generate_header() {
    printf "(id,%s)" "$(format_lines "${1}" "," identity)" ;
  }

  offer_options() {
    tasks="${1}" ;
    extra_properties="${2}" ;
    header="Select processes $(generate_header "${extra_properties}"):\n" ;
    if [[ -n "${3+x}" ]]; then
      shift ;
      shift ;
      command="Command: pueue ${*}
" ;
      header="${command}${header}" ;
    fi ;
    # `\(.id)` has to be first and is expected by `format_ids()` and `pueue_log` to be preceded by a comma.
    printf "%s" "${tasks}" \
      | jq -r --color-output ".[] \
      | \"\(.id),$(generate_jq_properties_output "${extra_properties}")\"" \
      | fzf --header "${header}" -m --preview="pueue_log {}" --preview-window="nohidden";
  }

  print_selected() {
    extra_properties="${1}" ;
    tasks="${2}" ;
    selected_ids="${3}" ;
    with_commas="$(printf "%s" "${selected_ids}" | tr ' ' ',')" ;
    printf "%s" "${tasks}" | jq --color-output -r ".[] | select(.id == (${with_commas})) | \"\(.id),$(generate_jq_properties_output "${extra_properties}")\"" ;
  }


  format_jq_properties_filter() {
    printf "%s: .%s" "${1}" "${1}" ;
  }

  # Edit this to add, remove or rearrange properties as desired.
  extra_properties="group
path
status
command
start" ;
  # `id: .id` has to be present.
  tasks="$(pueue status -j | jq -j "[.tasks | to_entries[] | [.value] | .[] | { id: .id, $(format_lines "${extra_properties}" ", " format_jq_properties_filter) }]")" ;
  if test "${#}" -eq 0 ; then
    selected_ids="$(print_ids "$(offer_options "${tasks}" "${extra_properties}")")" ;
    if [[ -n "${selected_ids}" ]]; then
      printf "Selections %s:\n%s\nInput subcommand and arguments: " "$(generate_header "${extra_properties}")" "$(print_selected "${extra_properties}" "${tasks}" "${selected_ids}")" ;
      read -r subcommand ;
      # Unquoted `${subcommand}` and `${selected_ids}` on purpose to cause word splitting.
      pueue ${subcommand} ${selected_ids} ;
    fi ;
  else
    selected_ids="$(print_ids "$(offer_options "${tasks}" "${extra_properties}" "${@}")")" ;
    if [[ -n "${selected_ids}" ]]; then
      # Unquoted `${selected_ids}` on purpose to cause word splitting.
      pueue "${@}" ${selected_ids} ;
    fi ;
  fi ;
}

pr() {
  pw restart -ik ;
}

pk() {
  pw kill ;
}
