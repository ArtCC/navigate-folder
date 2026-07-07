#!/bin/zsh

# Interactive folder navigation script for zsh - Version 2.2.0
# Author: Arturo Carretero Calvo

emulate -L zsh
setopt local_options no_nomatch null_glob

typeset -ga nav_folders
typeset -ga nav_favorites

nav_version="2.2.0"
nav_filter=""
nav_previous_dir=""
nav_selected=1
nav_editor="${NAV_EDITOR:-${VISUAL:-${EDITOR:-}}}"
nav_reset=$'\033[0m'
nav_bold=$'\033[1m'
nav_dim=$'\033[2m'
nav_reverse=$'\033[7m'
nav_blue=$'\033[34m'
nav_cyan=$'\033[36m'
nav_green=$'\033[32m'
nav_yellow=$'\033[33m'
nav_red=$'\033[31m'

show_help() {
    cat <<'EOF'
Usage: source navigate.sh [start-directory]

Controls:
  Up/Down  Move through the folder list
  Enter    Enter the highlighted folder
  1..n      Enter the selected folder
  0 or ..   Go up one level
  -         Go back to the previous directory
  /text     Filter folders by text
  /         Clear the current filter
  s         Search folders recursively
  h         Toggle hidden folders
  f         Show favorites
  o         Open current folder in Finder
  e         Open current folder in $NAV_EDITOR, $VISUAL, or $EDITOR
  .         Stay here and exit
  q         Exit

Environment:
  NAV_CLEAR=0          Disable screen clearing on each refresh
  NAV_SHOW_HIDDEN=1    Show hidden folders by default
  NAV_EDITOR="code"    Editor command used by the e shortcut
  NAV_FAVORITES="~/Downloads/Proyectos:~/Desktop"
  NAV_SEARCH_LIMIT=30  Maximum recursive search results shown
EOF
}

notice() {
    local color="$1"
    shift

    printf "%b%s%b\n" "$color" "$*" "$nav_reset"
}

expand_path() {
    local path="$1"
    print -r -- "${~path}"
}

folder_label() {
    local path="$1"

    if [[ "$path" == "$HOME" ]]; then
        print -r -- "~"
    elif [[ "$path" == "$HOME"/* ]]; then
        print -r -- "~/${path#$HOME/}"
    else
        print -r -- "$path"
    fi
}

build_favorites() {
    local raw_favorites="${NAV_FAVORITES:-$HOME/Downloads/Proyectos:$HOME/Documents:$HOME/Desktop:$HOME}"
    local favorite expanded

    nav_favorites=()

    for favorite in ${(s.:.)raw_favorites}; do
        expanded="$(expand_path "$favorite")"
        [[ -d "$expanded" ]] && nav_favorites+=("$expanded")
    done
}

show_directory() {
    [[ "${NAV_CLEAR:-1}" != "0" ]] && clear

    print ""
    printf "%b%s%b\n" "$nav_blue" "------------------------------------------------------------" "$nav_reset"
    printf "%b%s%b %bv%s%b\n" "$nav_bold" "NAVIGATE" "$nav_reset" "$nav_dim" "$nav_version" "$nav_reset"
    printf "%bCurrent%b  %s\n" "$nav_cyan" "$nav_reset" "$(folder_label "$PWD")"

    if [[ -n "$nav_filter" ]]; then
        printf "%bFilter%b   %s\n" "$nav_cyan" "$nav_reset" "$nav_filter"
    fi

    printf "%b%s%b\n" "$nav_blue" "------------------------------------------------------------" "$nav_reset"
}

show_folders() {
    local dir name lower_name lower_filter counter selected_marker
    local -a candidates

    nav_folders=()
    candidates=(*/)

    if [[ "${NAV_SHOW_HIDDEN:-0}" == "1" ]]; then
        candidates+=(.[!.]*/ ..?*/)
    fi

    lower_filter="${(L)nav_filter}"

    for dir in "${candidates[@]}"; do
        [[ -d "$dir" ]] || continue

        name="${dir%/}"
        lower_name="${(L)name}"

        if [[ -n "$lower_filter" && "$lower_name" != *"$lower_filter"* ]]; then
            continue
        fi

        nav_folders+=("$name")
    done

    if (( ${#nav_folders[@]} == 0 )); then
        nav_selected=1
        if [[ -n "$nav_filter" ]]; then
            notice "$nav_yellow" "  No folders match '$nav_filter'."
        else
            notice "$nav_yellow" "  No folders in this directory."
        fi
        return 1
    fi

    (( nav_selected < 1 )) && nav_selected=1
    (( nav_selected > ${#nav_folders[@]} )) && nav_selected=${#nav_folders[@]}

    counter=1
    for name in "${nav_folders[@]}"; do
        if (( counter == nav_selected )); then
            selected_marker=">"
            printf "%b %s %2d  %s %b\n" "$nav_reverse" "$selected_marker" "$counter" "$name" "$nav_reset"
        else
            selected_marker=" "
            printf "  %s %b%2d%b  %b%s%b\n" "$selected_marker" "$nav_cyan" "$counter" "$nav_reset" "$nav_bold" "$name" "$nav_reset"
        fi
        ((counter++))
    done

    return 0
}

search_folders() {
    local query lower_query folder lower_folder option selected index shown max_results
    local -a matches results

    print ""
    printf "%bSearch%b > " "$nav_bold" "$nav_reset"
    read -r query

    [[ -z "$query" ]] && return 1

    matches=(**/*(/N))

    if [[ "${NAV_SHOW_HIDDEN:-0}" == "1" ]]; then
        matches+=(.[!.]*/ ..?*/ .[!.]*/**/*(/N) ..?*/**/*(/N))
    fi

    lower_query="${(L)query}"
    results=()

    for folder in "${matches[@]}"; do
        lower_folder="${(L)folder}"
        [[ "$lower_folder" == *"$lower_query"* ]] && results+=("$folder")
    done

    if (( ${#results[@]} == 0 )); then
        notice "$nav_yellow" "No recursive matches for '$query'."
        return 1
    fi

    print ""
    printf "%bSearch Results%b for '%s'\n" "$nav_cyan" "$nav_reset" "$query"

    max_results="${NAV_SEARCH_LIMIT:-30}"
    shown=0
    index=1

    for folder in "${results[@]}"; do
        (( shown >= max_results )) && break
        printf "  %b%2d%b  %s\n" "$nav_cyan" "$index" "$nav_reset" "$folder"
        ((index++))
        ((shown++))
    done

    if (( ${#results[@]} > shown )); then
        notice "$nav_dim" "Showing first $shown of ${#results[@]} matches. Narrow your search to see fewer results."
    fi

    print "  q   Cancel"
    print ""
    printf "%bChoose result%b > " "$nav_bold" "$nav_reset"
    read -r option

    [[ "$option" == "q" || "$option" == "Q" ]] && return 1

    if [[ "$option" =~ '^[1-9][0-9]*$' && "$option" -le "$shown" ]]; then
        selected="${results[$option]}"
        change_directory "$selected"
        return $?
    fi

    notice "$nav_red" "Invalid search result."
    return 1
}

show_menu() {
    print ""
    printf "%bNavigation%b  ↑/↓ move   Enter open   0/.. up   - back   . stay   q quit\n" "$nav_cyan" "$nav_reset"
    printf "%bSearch%b      /text filter   / clear   s recursive\n" "$nav_cyan" "$nav_reset"
    printf "%bTools%b       f favorites   h hidden   o Finder   e editor\n" "$nav_cyan" "$nav_reset"
}

read_option() {
    local key rest query

    print ""
    printf "%bChoose%b > " "$nav_bold" "$nav_reset"

    if [[ ! -t 0 ]]; then
        if ! read -r option; then
            option="q"
        fi
        return 0
    fi

    if ! read -r -sk1 key; then
        option="q"
        return 0
    fi

    case "$key" in
        $'\e')
            read -r -sk2 rest || return 100
            case "$rest" in
                '[A')
                    (( nav_selected-- ))
                    return 100
                    ;;
                '[B')
                    (( nav_selected++ ))
                    return 100
                    ;;
            esac
            return 100
            ;;
        ''|$'\n'|$'\r')
            print ""
            if (( ${#nav_folders[@]} > 0 )); then
                option="$nav_selected"
            else
                option=""
            fi
            return 0
            ;;
        '/')
            print ""
            printf "%bFilter%b > " "$nav_bold" "$nav_reset"
            read -r query
            if [[ -n "$query" ]]; then
                option="/$query"
            else
                option="/"
            fi
            return 0
            ;;
        [0-9])
            option="$key"
            while read -r -sk1 -t 0.12 rest; do
                [[ "$rest" == [0-9] ]] || break
                option="$option$rest"
            done
            print ""
            return 0
            ;;
        *)
            print ""
            option="$key"
            return 0
            ;;
    esac
}

show_favorites() {
    local index=1 favorite label option

    if (( ${#nav_favorites[@]} == 0 )); then
        print ""
        notice "$nav_yellow" "No valid favorites. Set NAV_FAVORITES with colon-separated paths."
        return 1
    fi

    print ""
    printf "%bFavorites%b\n" "$nav_cyan" "$nav_reset"
    for favorite in "${nav_favorites[@]}"; do
        label="$(folder_label "$favorite")"
        printf "  %b%2d%b  %s\n" "$nav_cyan" "$index" "$nav_reset" "$label"
        ((index++))
    done

    print "  q) Cancel"
    print ""
    printf "Choose favorite: "
    read -r option

    if [[ "$option" == "q" || "$option" == "Q" ]]; then
        return 1
    fi

    if [[ "$option" =~ '^[1-9][0-9]*$' && -n "${nav_favorites[$option]}" ]]; then
        change_directory "${nav_favorites[$option]}"
        return $?
    fi

    notice "$nav_red" "Invalid favorite."
    return 1
}

change_directory() {
    local target="$1"
    local current="$PWD"

    if cd "$target" 2>/dev/null; then
        nav_previous_dir="$current"
        nav_filter=""
        nav_selected=1
        notice "$nav_green" "Entered: $(folder_label "$PWD")"
        return 0
    fi

    notice "$nav_red" "Could not access: $target"
    return 1
}

go_up() {
    if [[ "$PWD" == "/" ]]; then
        notice "$nav_yellow" "Already at system root."
        return 1
    fi

    change_directory ".."
}

go_back() {
    if [[ -z "$nav_previous_dir" || ! -d "$nav_previous_dir" ]]; then
        notice "$nav_yellow" "No previous directory available."
        return 1
    fi

    change_directory "$nav_previous_dir"
}

open_editor() {
    if [[ -z "$nav_editor" ]]; then
        notice "$nav_yellow" "No editor configured. Set NAV_EDITOR, VISUAL, or EDITOR."
        return 1
    fi

    command ${(z)nav_editor} . >/dev/null 2>&1 &!
    notice "$nav_green" "Opened editor: $nav_editor ."
}

process_option() {
    local option="$1"
    local selected

    case "$option" in
        q|Q|quit|exit)
            notice "$nav_dim" "Goodbye."
            return 99
            ;;
        .)
            notice "$nav_green" "Staying in: $(folder_label "$PWD")"
            return 99
            ;;
        0|..)
            go_up
            return $?
            ;;
        -)
            go_back
            return $?
            ;;
        /)
            nav_filter=""
            nav_selected=1
            return 0
            ;;
        /*)
            nav_filter="${option#/}"
            nav_selected=1
            return 0
            ;;
        h|H)
            if [[ "${NAV_SHOW_HIDDEN:-0}" == "1" ]]; then
                NAV_SHOW_HIDDEN=0
                notice "$nav_yellow" "Hidden folders disabled."
            else
                NAV_SHOW_HIDDEN=1
                notice "$nav_green" "Hidden folders enabled."
            fi
            nav_selected=1
            return 0
            ;;
        s|S)
            search_folders
            return $?
            ;;
        f|F)
            show_favorites
            return $?
            ;;
        o|O)
            open .
            notice "$nav_green" "Opened in Finder."
            return 0
            ;;
        e|E)
            open_editor
            return $?
            ;;
    esac

    if [[ "$option" =~ '^[1-9][0-9]*$' ]]; then
        selected="${nav_folders[$option]}"
        if [[ -n "$selected" ]]; then
            change_directory "$selected"
            return $?
        fi

        notice "$nav_red" "Number out of range. Choose between 1 and ${#nav_folders[@]}."
        return 1
    fi

    notice "$nav_red" "Invalid option. Use a number, shortcut, /filter, or q."
    return 1
}

main() {
    local option result start_dir

    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_help
        return 0
    fi

    build_favorites

    if [[ -n "$1" ]]; then
        start_dir="$(expand_path "$1")"
        if [[ -d "$start_dir" ]]; then
            cd "$start_dir" 2>/dev/null || notice "$nav_red" "Could not access: $1"
        else
            notice "$nav_red" "Start directory does not exist: $1"
        fi
    fi

    while true; do
        show_directory
        show_folders
        show_menu

        read_option
        result=$?

        (( result == 100 )) && continue

        process_option "$option"
        result=$?

        (( result == 99 )) && break
        sleep 0.15
    done
}

main "$@"
nav_status=$?

unfunction show_help notice expand_path folder_label build_favorites show_directory show_folders search_folders show_menu read_option show_favorites change_directory go_up go_back open_editor process_option main 2>/dev/null
unset nav_folders nav_favorites nav_version nav_filter nav_previous_dir nav_selected nav_editor nav_reset nav_bold nav_dim nav_reverse nav_blue nav_cyan nav_green nav_yellow nav_red option result start_dir 2>/dev/null

return "$nav_status" 2>/dev/null || exit "$nav_status"
