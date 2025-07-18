#!/bin/bash
if [ "$EUID" -eq 0 ]; then
  echo "Ne rootként futtasd ezt a scriptet! Kérlek, indítsd normál felhasználóként."
  exit 1
fi

API_KEY_FILE=".virtualpet_api_key"
API_URL="http://cmdgochi.mooo.com:5555"
API_KEY=""
LANG_CHOICE_FILE=".lang"

function logo() {
  clear
  ART=$(cat <<'EOF'
 ▗▄▄▖▗▖  ▗▖▗▄▄▄   ▗▄▄▖ ▄▄▄  ▗▞▀▘▐▌   ▄
▐▌   ▐▛▚▞▜▌▐▌  █ ▐▌   █   █ ▝▚▄▖▐▌   ▄
▐▌   ▐▌  ▐▌▐▌  █ ▐▌▝▜▌▀▄▄▄▀     ▐▛▀▚▖█
▝▚▄▄▖▐▌  ▐▌▐▙▄▄▀ ▝▚▄▞▘          ▐▌ ▐▌█
EOF
)

  colors=(31 33 32 36 34 35)

  i=0
  while IFS= read -r line; do
    color=${colors[$((i % ${#colors[@]}))]}
    echo -e "\e[${color}m$line\e[0m"
    ((i++))
  done <<< "$ART"

}

check_for_updates() {
    logo
    VERSION_FILE=".version"
    LOCAL_VERSION="1.0.0"

    if [[ -f "$VERSION_FILE" ]]; then
        LOCAL_VERSION=$(<"$VERSION_FILE")
    fi

    REMOTE_VERSION_URL="https://raw.githubusercontent.com/Pucur/CMDGochi/main/.version"
    REMOTE_VERSION=$(curl -s "$REMOTE_VERSION_URL")

    if [[ -z "$REMOTE_VERSION" ]]; then
        echo "$REMOTE_VERSION_ERROR"
        return
    fi

    if [[ "$REMOTE_VERSION" != "$LOCAL_VERSION" ]]; then
        echo "${NEW_VERSION_AVAILABLE//%REMOTE%/$REMOTE_VERSION}" | sed "s/%LOCAL%/$LOCAL_VERSION/"
        echo "$UPDATING_CLIENT"

        echo "$REMOTE_VERSION" > "$VERSION_FILE"

        git pull origin main

        echo "$UPDATE_DONE"
        exit 0
    fi

    echo "Nincs új verzió."
}





function choose_language() {
    logo
    if [[ -f "$LANG_CHOICE_FILE" ]]; then
        LANG_FILE=$(<"$LANG_CHOICE_FILE")
        if [[ ! -f "$LANG_FILE" ]]; then
            rm -f "$LANG_CHOICE_FILE"
            choose_language
            return
        fi
    else
while true; do
  echo "Válassz nyelvet / Choose language / Sprache wählen:"
  echo "1) Magyar"
  echo "2) English"
  echo "3) Deutsch"
  echo "4) Français"
  echo "5) Español"
  echo "6) Italiano"
  echo "7) Nederlands"
  echo "8) Čeština"
  echo "9) Polski"
  read -rp "Choose one: " choice
  case $choice in
    1) LANG_FILE="lang/hu.lang"; break ;;
    2) LANG_FILE="lang/en.lang"; break ;;
    3) LANG_FILE="lang/de.lang"; break ;;
    4) LANG_FILE="lang/fr.lang"; break ;;
    5) LANG_FILE="lang/es.lang"; break ;;
    6) LANG_FILE="lang/it.lang"; break ;;
    7) LANG_FILE="lang/nl.lang"; break ;;
    8) LANG_FILE="lang/cz.lang"; break ;;
    9) LANG_FILE="lang/pl.lang"; break ;;
    *)
    logo
    echo "Unknown language, please choose again!" ;;
  esac
done

        if [[ ! -f "$LANG_FILE" ]]; then
            echo "A(z) $LANG_FILE nem található! Kilépés."
            exit 1
        fi

        echo "$LANG_FILE" > "$LANG_CHOICE_FILE"
    fi

    source "$LANG_FILE"

    if [[ -z "${MENU_LOGIN}" ]]; then
        echo "A $LANG_FILE üres vagy nem megfelelően van kitöltve!"
        exit 1
    fi
}

choose_language
check_for_updates

function save_api_key() {
    local old_key
    old_key=$(<"$API_KEY_FILE")
    echo "$API_KEY" > "$API_KEY_FILE"
    echo "# Régi API kulcs: $old_key" >> "$API_KEY_FILE"
    chmod 600 "$API_KEY_FILE"
    pet_menu
}

function load_api_key() {
    if [[ -f "$API_KEY_FILE" ]]; then
        #API_KEY=$(<"$API_KEY_FILE")
        API_KEY=$(grep -v '^#' "$API_KEY_FILE" | head -n 1)

    else
        API_KEY=""
    fi
}

function ask_for_api_key() {
    load_api_key
    if [[ -n "$API_KEY" ]]; then
        echo "Jelenlegi API kulcs: $API_KEY"
        pet_menu
    fi
    register_new_api_key
}

function register_new_api_key() {
    load_language

    echo "$REQUEST_NEW_API_KEY"
    API_KEY=$(curl -s -X POST "$API_URL/register" -H "Content-Type: application/json" | jq -r '.api_key')

    if [[ -z "$API_KEY" || "$API_KEY" == "null" ]]; then
        echo "$API_KEY_REGISTRATION_ERROR"
        exit 1
    fi
    save_api_key
}

function edit_api_key_menu() {
    load_api_key
    load_language

    while true; do
        logo
        echo
        echo "====================== ${API_KEY_MENU_TITLE} ======================"
        echo "|                                                            |"
        echo "| ${API_KEY_MENU_CURRENT}${API_KEY:-Nincs beállítva}  |"
        echo "|                                                            |"
        echo "| ${API_KEY_MENU_OPTION_1}                                         |"
        echo "| ${API_KEY_MENU_OPTION_2}                                  |"
        echo "| ${API_KEY_MENU_OPTION_3}                                |"
        echo "| ${API_KEY_MENU_OPTION_4}                                           |"
        echo "| ${API_KEY_MENU_OPTION_5}                                       |"
        echo "|____________________________________________________________|"
        read -rp "${API_KEY_MENU_PROMPT}" choice

        case "$choice" in
            1)
                register_new_api_key
                ;;
            2)
                echo -n "${API_KEY_ENTER_EXISTING}"
                read -r API_KEY
                save_api_key
                echo "${API_KEY_UPDATED}"
                ;;
            3)
                logo
                if [[ -f "$API_KEY_FILE" ]]; then
                    if [[ -s "$API_KEY_FILE" ]]; then
                        echo ""
                        echo "===== API Kulcsok ====="
                        echo ""
                        cat "$API_KEY_FILE"
                    else
                        echo "${API_KEY_FILE_EMPTY}"
                    fi
                else
                    echo "${API_KEY_FILE_MISSING}"
                fi
                echo ""
                read -rp "${PRESS_ENTER_BACK}"
                ;;
            4)
                if [[ -f "$API_KEY_FILE" ]]; then
                    sed -i '1s/^/# Régi API kulcs: /' "$API_KEY_FILE"
                fi
                API_KEY=""
                echo "${API_KEY_DELETED}"
                ;;
            5)
                main_menu
                ;;
            *)
                echo "${INVALID_CHOICE}"
                ;;
        esac
    done
}

function show_ascii_pet() {
    local type="$1"
    case "$type" in
        cat)
            echo "        .^----^."
            echo "      (= o  O =)"
            echo "       (___V__)"
            echo "        _|==|_"
            echo "   ___/' |--| |"
            echo "  / ,._| |  | '"
            echo " | \\__ |__}-|__}"
            echo "  \\___)''";;
        dog)
            echo "                           __"
            echo "     ,                    ,\" e\`--o"
            echo "    ((                   (  | __,'"
            echo "     \\\\~----------------' \\_;/"
            echo "     (                      /"
            echo "     /) ._______________.  )"
            echo "    (( (               (( ("
            echo "     \`\`-'               \`\`-'";;

        parrot)
            echo "        ______ __"
            echo "       {-_-_= '. \`'."
            echo "        {=_=_-  \\   \\"
            echo "         {_-_   |   /"
            echo "          '-.   |  /    .===,"
            echo "       .--.__\\  |_(_,==\`  ( o)'-."
            echo "      \`---.=_ \`     ;      \`/    \\"
            echo "          \`,-_       ;    .'--') /"
            echo "            {=_       ;=~\`    \`\""
            echo "             \`//__,-=~\`"
            echo "             <<__ \\\\__"
            echo "             /\`)))/\`)))";;
        hamster)
            echo "             .     ."
            echo "            (>\\---/<)"
            echo "            ,'     '."
            echo "           /  q   p  \\"
            echo "          (  >(_Y_)<  )"
            echo "           >-' '-' '-<-."
            echo "          /  _.== ,=.,- \\"
            echo "         /,    )'  '(    )"
            echo "        ; '._.'      '--<"
            echo "       :     \\        |  )"
            echo "       \\      )       ;_/  "
            echo "        '._ _/_  ___.'-\\\\\\"
            echo "           '--\\\\\\";;

        rabbit)
            echo "       _"
            echo "      (\\"
            echo "       \\||"
            echo "     __(');"
            echo "    /    \\"
            echo "   {}___)\\)_";;

        mouse)
            echo "     .--,       .--,"
            echo "    ( (  \\.---./  ) )"
            echo "     '.__/o   o\\__.'"
            echo "        {=  ^  =}"
            echo "         >  -  <"
            echo "        /       \\"
            echo "       //       \\\\"
            echo "      //|   .   |\\\\"
            echo "      \"'\\       /'\"_.-~^`'-."
            echo "         \\  _  /--'         `"
            echo "       ___)( )(___";;

        raccoon)
            echo "                   __        .-."
            echo "               .-\"` .\'`''.    /\\|"
            echo "       _(\\-/)_\" ,  .   ,\\  /\\\\\\/"
            echo "      {(#b^d#)} .   ./,  |/\\\\\\/"
            echo "      \`-.(Y).-'  ,  |  , |\\.-\'"
            echo "           /~/,_/~~~\\,__.-\`"
            echo "          ////~    // ~\\\\"
            echo "     ==\`==\`   ==\`   ==\'''";;
        badger)
            echo "                ___,,___"
            echo "           _,-='=- =-  -\`\"--.__,,.._"
            echo "        ,-;// /  - -       -   -= - \"=."
            echo "      ,'///    -     -   -   =  - ==-=\`."
            echo "     |/// /  =    \`. - =   == - =.=_,,._ \`=/|"
            echo "    ///    -   -    \\  - - = ,ndDMHHMM/\\b  \\\\"
            echo "  ,' - / /        / /\\ =  - /MM(,,._\`YQMML  \`|"
            echo " <_,=^Kkm / / / / ///H|wnWWdMKKK#\"\"-;. \`\"0\\  |"
            echo "        \`\"\"QkmmmmmnWMMM\\\"WHMKKMM\\   \`--. \\> \\"
            echo "              \`\"\"'  \`->>>    \`\`WHMb,.    \`-_<@)"
            echo "                                \`\"QMM\`."
            echo "                                   \`>>>\"";;

        *)
            echo "   ?????"
            echo "  ( o_O )"
            echo "  /|   |\\"
            echo "   |___|"
            echo "  ¯\\_(ツ)_/¯" ;;
    esac
}

print_underline() {
  local cols=$(tput cols)
  for ((i=0; i<cols; i++)); do echo -n "_"; done
  echo
}

print_overline() {
  local cols=$(tput cols)
  for ((i=0; i<cols; i++)); do echo -n "¯"; done
  echo
}

print_padded_line() {
  local line="$1"
  local cols=$(tput cols)
  local len=${#line}
  local spaces=$((cols - len - 1))
  ((spaces < 0)) && spaces=0
  printf "%s%*s|\n" "$line" "$spaces" ""
}

function show_leaderboard() {
    load_language
    logo
    cols=$(tput cols)
    response=$(curl -s -X GET "$API_URL/top-pets" -H "Content-Type: application/json")

    echo ""
    echo "===== ${TOP10_TITLE} ====="

    print_underline
    line="|"
    print_padded_line "$line"

    echo "$response" | jq -r '.top_pets[] | [.name, (.age_days|tostring), (.level|tostring), .type, (.health), (.happiness)] | @tsv' | \
    while IFS=$'\t' read -r name age level type health happiness; do
        health_int=$(printf "%.0f" "$health")
        happy_int=$(printf "%.0f" "$happiness")
        line=$(printf "| ${NAME_LABEL}: %-20s | ${AGE_LABEL}: %-5s %s | ${LEVEL_LABEL}: %-5s | ${TYPE_LABEL}: %-10s | ${HEALTH_LABEL}: %3s%% | ${HAPPINESS_LABEL}: %3s%% |" \
                     "$name" "$age" "$AGE_UNIT" "$level" "$type" "$health_int" "$happy_int")
        print_padded_line "$line"
    done

    line="|"
    print_padded_line "$line"
    print_overline

    read -p "${STATS_CONTINUE_PROMPT}"

    logo
    echo
    echo "===== ${SUMMARY_TITLE} ====="
    echo
    print_underline

    line="|                              |"
    print_padded_line "$line"

    summary_line=$(echo "$response" | jq -r --arg total_label "$TOTAL_PETS_LABEL" \
                                           --arg avg_level_label "$AVG_LEVEL_LABEL" \
                                           --arg avg_age_label "$AVG_AGE_LABEL" \
                                           --arg avg_age_unit "$AGE_UNIT" \
                                           --arg avg_health_label "$AVG_HEALTH_LABEL" \
                                           --arg avg_happiness_label "$AVG_HAPPINESS_LABEL" '
        .summary as $s |
        [
          "\($total_label): \($s.total_pets)",
          "\($avg_level_label): \($s.average_level)",
          "\($avg_age_label): \($s.average_age_days) \($avg_age_unit)",
          "\($avg_health_label): \($s.average_health)",
          "\($avg_happiness_label): \($s.average_happiness)"
        ] | @tsv')

    echo "$summary_line" | while IFS=$'\t' read -r total avg_lvl avg_age avg_health avg_happy; do
        line=$(printf "| %-30s | %-15s | %-20s | %-17s | %-17s |" "$total" "$avg_lvl" "$avg_age" "$avg_health" "$avg_happy")
        print_padded_line "$line"
    done

    line="| ${TYPE_DISTRIBUTION_LABEL}                 |"
    print_padded_line "$line"
    line="|                              |"
    print_padded_line "$line"

    echo "$response" | jq -r --arg key_label "key" --arg val_label "value" '
        .summary.type_distribution | to_entries | map("\(.key)\t\(.value)") | .[]' | \
    while IFS=$'\t' read -r key val; do
        line=$(printf "| %-12s : %-13s |" "$key" "$val")
        print_padded_line "$line"
    done

    line="|"
    print_padded_line "$line"
    print_overline
    echo

    read -p "${MAIN_MENU_PROMPT}"
    main_menu
}






function get_pets() {
    curl -s -X GET "$API_URL/pet" -H "X-API-KEY: $API_KEY" -H "Content-Type: application/json"
}

function print_pets() {
    load_language
    logo
    pets_json=$(get_pets)

    if [[ -z "$pets_json" || "$pets_json" == "[]" ]]; then
        echo "$NO_PETS_LABEL"
        return
    fi

    echo
    echo "===== $PET_LIST_TITLE ====="
    cols=$(tput cols)
    for ((i = 0; i < cols; i++)); do echo -n "_"; done
    echo

    echo "$pets_json" | jq -c '.[]' | while read -r pet_json; do
        echo "$pet_json" | jq -r "
            def magyarosit:
                if . == \"cat\" then \"$CAT_LABEL\"
                elif . == \"dog\" then \"$DOG_LABEL\"
                elif . == \"parrot\" then \"$PARROT_LABEL\"
                elif . == \"hamster\" then \"$HAMSTER_LABEL\"
                elif . == \"rabbit\" then \"$RABBIT_LABEL\"
                elif . == \"mouse\" then \"$MOUSE_LABEL\"
                elif . == \"raccoon\" then \"$RACCOON_LABEL\"
                elif . == \"badger\" then \"$BADGER_LABEL\"
                else . end;

            [
              \"| ID: \(.id)\",
              \"| $NAME_LABEL: \(.name)\",
              \"| $AGE_LABEL: [\(.age_days) $AGE_UNIT]\",
              \"| $LEVEL_LABEL: [\(.level)]\",
              \"| $HEALTH_LABEL: \(.health | round) %\",
              \"| $TYPE_LABEL: \((.type | magyarosit))\"
            ] | @tsv
        " | while IFS=$'\t' read -r id name age level health type; do
            line=$(printf "%-8s %-25s %-22s %-15s %-19s %-3s" "$id" "$name" "$age" "$level" "$health" "$type")
            len=${#line}
            spaces=$((cols - len - 1))
            ((spaces < 0)) && spaces=0
            printf "%s%*s|\n" "$line" "$spaces" ""
        done
    done

    print_overline
    echo ""
}

function pet_action() {
    local pet_id=$1
    local action=$2

    response=$(curl -s -X POST "$API_URL/pet/$pet_id/$action" -H "X-API-KEY: $API_KEY" -H "Content-Type: application/json")
}

function delete_pet() {
    local pet_id=$1
    response=$(curl -s -X DELETE "$API_URL/pet/$pet_id" -H "X-API-KEY: $API_KEY" -H "Content-Type: application/json")
}


function get_pet_status() {
    local pet_id=$1
    response=$(curl -s -X GET "$API_URL/pet" -H "X-API-KEY: $API_KEY" -H "Content-Type: application/json")
    pet_json=$(echo "$response" | jq -r --arg id "$pet_id" '.[] | select(.id == ($id|tonumber))')
    pet_type=$(echo "$pet_json" | jq -r '.type')
    show_ascii_pet "$pet_type"

    print_underline
    local needs_bath_val=$(echo "$pet_json" | jq -r '.needs_bath')
    local is_sick_val=$(echo "$pet_json" | jq -r '.is_sick')

    local bath_status=""
    local sick_status=""

    case "$needs_bath_val" in
        1) bath_status="$BATH_DIRTY" ;;
        0) bath_status="$BATH_CLEAN" ;;
        *) bath_status="?" ;;
    esac

    case "$is_sick_val" in
        1) sick_status="$SICK_YES" ;;
        0) sick_status="$SICK_NO" ;;
        *) sick_status="?" ;;
    esac

    echo "$pet_json" | jq -r --arg name_lbl "$NAME_LABEL" \
                               --arg age_lbl "$AGE_LABEL" \
                               --arg lvl_lbl "$LEVEL_LABEL" \
                               --arg hunger_lbl "$HUNGER_LABEL" \
                               --arg happy_lbl "$HAPPINESS_LABEL" \
                               --arg energy_lbl "$ENERGY_LABEL" \
                               --arg bath_lbl "$BATH_LABEL" \
                               --arg sick_lbl "$SICK_LABEL" \
                               --arg health_lbl "$HEALTH_LABEL" \
                               --arg age_unit "$AGE_UNIT" \
                               --arg bath_txt "$bath_status" \
                               --arg sick_txt "$sick_status" '
      [
        "| \($name_lbl): \(.name) || \($age_lbl): [\(.age_days) \($age_unit)] || \($lvl_lbl): [\(.level)]",
        "| \($hunger_lbl): \(.hunger | round) % || \($happy_lbl): \(.happiness | round) % || \($energy_lbl): \(.energy | round) %",
        "| \($bath_lbl): \($bath_txt) || \($sick_lbl): \($sick_txt) || \($health_lbl): \(.health | round) %"
      ] | .[]' | while IFS= read -r line; do
        len=${#line}
        spaces=$((cols - len - 1))
        ((spaces < 0)) && spaces=0
        printf "%s%*s|\n" "$line" "$spaces" ""
    done

    print_overline
    echo
}



function create_pet() {
    load_language
    logo
    echo -n "${ENTER_NAME_LABEL}: "
    read -r NEW_PET_NAME

    echo "$CHOOSE_TYPE_LABEL"
    echo "1) ${CAT_LABEL}    2) ${DOG_LABEL}    3) ${PARROT_LABEL}    4) ${HAMSTER_LABEL}"
    echo "5) ${RABBIT_LABEL} 6) ${MOUSE_LABEL}  7) ${RACCOON_LABEL}   8) ${BADGER_LABEL}"

    read -rp "${SELECT_LABEL} (1-8): " type_choice

    case "$type_choice" in
        1) pet_type="cat" ;;
        2) pet_type="dog" ;;
        3) pet_type="parrot" ;;
        4) pet_type="hamster" ;;
        5) pet_type="rabbit" ;;
        6) pet_type="mouse" ;;
        7) pet_type="raccoon" ;;
        8) pet_type="badger" ;;
        *) pet_type="cat" ;;
    esac

    response=$(curl -s -X POST "$API_URL/pet" \
        -H "X-API-KEY: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$NEW_PET_NAME\", \"type\":\"$pet_type\"}")

    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        new_id=$(echo "$response" | jq -r '.id')
        echo "$PET_CREATED_LABEL: ID $new_id, ${NAME_LABEL}: $NEW_PET_NAME"
    elif echo "$response" | jq -e '.message' > /dev/null 2>&1; then
        echo "$(echo "$response" | jq -r '.message')"
    else
        echo "$PET_CREATE_ERROR_LABEL"
        echo "$response"
    fi
}


function pet_menu() {
    logo
    echo $API_KEY
    while true; do
        echo
        print_pets
        echo
        echo "$SELECT_PET_LABEL"
        echo ""
        echo "  new  - $CREATE_NEW_PET_LABEL"
        echo "  exit - $EXIT_PET_MENU_LABEL"
        echo ""
        read -rp "$CHOICE_LABEL " PET_ID

        if [[ "$PET_ID" == "exit" ]]; then
            main_menu
        elif [[ "$PET_ID" == "new" ]]; then
            create_pet
            continue
        fi

        pet_status=$(get_pet_status "$PET_ID")
        if [[ -z "$pet_status" ]]; then
            echo "$PET_NOT_FOUND_LABEL"
            continue
        fi

        while true; do
            logo
            echo
            echo "$pet_status"
            echo

            if echo "$response" | jq -e '.message' > /dev/null 2>&1; then
                echo "$(echo "$response" | jq -r '.message')"
            fi

            echo "$WHAT_TO_DO_LABEL"
            echo
            echo "1) $FEED_LABEL"
            echo "2) $PLAY_LABEL"
            echo "3) $SLEEP_LABEL"
            echo "4) $BATHE_LABEL"
            echo "5) $MEDICATE_LABEL"
            echo "6) $DELETE_LABEL"
            echo "7) $BACK_LABEL"
            read -rp "$CHOICE_LABEL (1-7): " ACTION_NUM

            case "$ACTION_NUM" in
                1) ACTION_EN="feed" ;;
                2) ACTION_EN="play" ;;
                3) ACTION_EN="sleep" ;;
                4) ACTION_EN="bath" ;;
                5) ACTION_EN="medicate" ;;
                6)
                    echo -n "$CONFIRM_DELETE_LABEL: "
                    read -r CONFIRM
                    if [[ "$CONFIRM" == "igen" ]]; then
                        delete_pet "$PET_ID"
                        break
                    else
                        echo "$DELETE_ABORTED_LABEL"
                        sleep 2
                    fi
                    continue
                    ;;
                7)
                    break
                    ;;
                *)
                    echo "$INVALID_CHOICE"
                    sleep 2
                    continue
                    ;;
            esac

            if [[ $ACTION_NUM -ge 1 && $ACTION_NUM -le 5 ]]; then
                pet_action "$PET_ID" "$ACTION_EN"
                pet_status=$(get_pet_status "$PET_ID")
            fi
        done
    done
}

function about(){
logo
echo "$ABOUT_ME"
output=$(show_ascii_pet raccoon)
printf '%s\n' "$output"

read -p "OK"

}

function main_menu() {
    while true; do
        logo
        echo ""
        echo "$MAIN_MENU_HEADER"
        printf "| %-26s |\n" ""
        printf "| 1) %-23s |\n" "$MENU_LOGIN"
        printf "| 2) %-23s |\n" "$MENU_API_KEY"
        printf "| 3) %-23s |\n" "$MENU_LEADERBOARD"
        printf "| 4) %-23s |\n" "$MENU_ABOUT"
        printf "| 5) %-23s |\n" "$MENU_EXIT"
        echo "|____________________________|"
        echo ""
        read -rp "$CHOICE_LABEL (1-5): " main_choice

        case "$main_choice" in
            1)
                ask_for_api_key
                ;;
            2)
                edit_api_key_menu
                ;;
            3)
                show_leaderboard
                ;;
            4)
                about
                ;;
            5)
                echo "$GOODBYE_LABEL"
                exit 0
                ;;
            *)
                echo "$INVALID_CHOICE"
                ;;
        esac
    done
}


main_menu
