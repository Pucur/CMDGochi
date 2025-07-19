#!/bin/bash
export LC_ALL=C
if [ "$EUID" -eq 0 ]; then
  echo "Don't run this script as root! Please start it as a regular user."
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
        git reset --hard
        git pull origin main

        echo "$UPDATE_DONE"
        exit 0
    fi
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
            printf "\nVálassz nyelvet / Choose language / Sprache wählen:\n\n"
            echo "1) Magyar"
            echo "2) English"
            echo "3) Deutsch"
            echo "4) Français"
            echo "5) Español"
            echo "6) Italiano"
            echo "7) Nederlands"
            echo "8) Čeština"
            printf "9) Polski\n\n"
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
                    printf " \nUnknown language, please choose again!\n\n" ;;
            esac
        done

        echo "$LANG_FILE" > "$LANG_CHOICE_FILE"
    fi

    source "$LANG_FILE"
}
choose_language
check_for_updates

function save_api_key() {
    local old_key
    old_key=$(<"$API_KEY_FILE")
    echo "$API_KEY" > "$API_KEY_FILE"
    echo "# $API_OLD_KEY: $old_key" >> "$API_KEY_FILE"
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
        pet_menu
    fi
    register_new_api_key
}

function register_new_api_key() {
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

    while true; do
        logo
        printf "\n${SETTINGS_TITLE}\n"
        printf "|%b\t\t\t\t\t\t\t\t|\n"
        printf "| %b\t|\n" "${API_KEY_MENU_CURRENT}${API_KEY:-${API_KEY_FILE_MISSING}}"
        printf "|%b\t\t\t\t\t\t\t\t|\n"
        printf "| 1) %b|\n" "${SETTINGS_MENU_1}"
        printf "| 2) %b|\n" "${SETTINGS_MENU_2}"
        printf "| 3) %b|\n" "${SETTINGS_MENU_3}"
        printf "| 4) %b|\n" "${SETTINGS_MENU_4}"
        printf "| 5) %b|\n" "${SETTINGS_MENU_5}"
        printf "| 6) %b|\n" "${SETTINGS_MENU_6}"
        printf "|_______________________________________________________________|\n\n"
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
                        printf "\n===== %s =====\n\n" "$API_KEYS"
                        cat "$API_KEY_FILE"
                    else
                        echo "${API_KEY_FILE_EMPTY}"
                    fi
                else
                    printf " \n${API_KEY_FILE_MISSING}\n"
                fi
                echo ""
                read -rp "${PRESS_ENTER_BACK}"
                ;;
            4)
                if [[ -f "$API_KEY_FILE" ]]; then
                    sed -i "1s/^/# $API_OLD_KEY: /" "$API_KEY_FILE"
                fi
                API_KEY=""
                echo "${API_KEY_DELETED}"
                ;;
            5)
                rm -f "$LANG_CHOICE_FILE"
                choose_language
                ;;
            6)
                main_menu
                ;;
            *)
                printf "\n${INVALID_CHOICE}\n\n"
                read -rp "${PRESS_ENTER_BACK}"
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
            echo "               .-\"''.\`''.    /\\|"
            echo "       _(\-/)_\" ,  .   ,\\  /\\\\\\/"
            echo "      {(#b^d#)} .   ./,  |/\\\\\\/"
            echo "      \`-.(Y).-\'  ,  |  , |\\.-\'"
            echo "           /~/,_/~~~\\,__.-\`"
            echo "          ////~    // ~\\\\"
            echo "     ==\`==\`   ==\`   ==\\'''";;
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
            echo "   |___|";;
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
  printf "%s%*s\t\t|\n" "$line" "$spaces" ""
}
function translate_type() {
    local type="$1"
    local type_upper=$(echo "$type" | tr '[:lower:]' '[:upper:]')
    local label_var="${type_upper}_LABEL"
    echo "${!label_var:-$type}"
}

function show_leaderboard() {
    logo
    response=$(curl -s -X GET "$API_URL/top-pets" -H "Content-Type: application/json")

    echo ""
    echo "===== ${TOP10_TITLE} ====="

    print_underline
    line="|"
    print_padded_line "$line"

    echo "$response" | jq -r '.top_pets[] | [.name, (.age_days|tostring), (.level|tostring), .type, (.health), (.happiness)] | @tsv' | \
    while IFS=$'\t' read -r name age level type health happiness; do
        translated_type=$(translate_type "$type")
        health_int=$(printf "%.0f" "$health")
        happy_int=$(printf "%.0f" "$happiness")

        line=$(printf "| ${NAME_LABEL}: %-20s | ${AGE_LABEL}: %-5s %s | ${LEVEL_LABEL}: %-5s | ${HEALTH_LABEL}: %3s%% | ${HAPPINESS_LABEL}: %3s%% | ${TYPE_LABEL}: %-10s" \
                 "$name" "$age" "$AGE_UNIT" "$level" "$health_int" "$happy_int" "$translated_type")
        print_padded_line "$line"
    done

    line="|"
    print_padded_line "$line"
    print_overline

    read -p "${STATS_CONTINUE_PROMPT}"

    logo
    echo
    echo "===== ${SUMMARY_TITLE} ====="
    print_underline

    line="|"
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
        line=$(printf "| %-15s | %-15s | %-20s | %-17s | %-17s" "$total" "$avg_lvl" "$avg_age" "$avg_health" "$avg_happy")
        print_padded_line "$line"
    done

    line="|"
    print_padded_line "$line"

    line=$(printf "| %s" "$TYPE_DISTRIBUTION_LABEL")
    print_padded_line "$line"

    line="|"
    print_padded_line "$line"

    echo "$response" | jq -r '.summary.type_distribution | to_entries | map("\(.key)\t\(.value)") | .[]' | \
while IFS=$'\t' read -r key val; do
    translated_key=$(translate_type "$key")
    line=$(printf "| %-5s %-15s" "$val" "$translated_key")
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
    logo
    pets_json=$(get_pets)

    if [[ -z "$pets_json" || "$pets_json" == "[]" ]]; then
        echo "$NO_PETS_LABEL"
        return
    fi

    printf "\n %s\n" "===== $PET_LIST_TITLE ====="
    print_underline
    print_padded_line "|"
    echo "$pets_json" | jq -c '.[]' | while read -r pet_json; do
        type=$(echo "$pet_json" | jq -r '.type')
        translated_type=$(translate_type "$type")

        echo "$pet_json" | jq -r --arg type_label "$translated_type" --arg name_label "$NAME_LABEL" \
                                    --arg age_label "$AGE_LABEL" --arg age_unit "$AGE_UNIT" \
                                    --arg level_label "$LEVEL_LABEL" --arg health_label "$HEALTH_LABEL" '
            [
              ("ID: " + (.id|tostring)),
              ($name_label + ": " + .name),
              ($age_label + ": [" + (.age_days|tostring) + " " + $age_unit + "]"),
              ($level_label + ": [" + (.level|tostring) + "]"),
              ($health_label + ": " + (.health|round|tostring) + " %"),
              ("Fajta: " + $type_label)
            ] | @tsv
        ' | while IFS=$'\t' read -r id name age level health type; do
            line=$(printf "| %-8s | %-25s | %-22s | %-15s | %-19s | %-10s" "$id" "$name" "$age" "$level" "$health" "$type")
            while (( ${#line} < cols - 1 )); do
                line+=" "
            done
            print_padded_line "${line}"
        done
    done
    print_padded_line "|"
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
      "| \($name_lbl): \(.name) | \($age_lbl): [\(.age_days) \($age_unit)] | \($lvl_lbl): [\(.level)]",
      "| \($hunger_lbl): \(.hunger | round) % | \($happy_lbl): \(.happiness | round) % | \($energy_lbl): \(.energy | round) %",
      "| \($bath_lbl): \($bath_txt) | \($sick_lbl): \($sick_txt) | \($health_lbl): \(.health | round) %"
    ] | .[]' | while IFS= read -r line; do
      print_padded_line "$line"
  done

  print_overline
  echo
}

create_pet() {
    logo

    while true; do
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

        response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/pet" \
            -H "X-API-KEY: $API_KEY" \
            -H "Content-Type: application/json" \
            -d "{\"name\":\"$NEW_PET_NAME\", \"type\":\"$pet_type\"}")

        http_code=$(echo "$response" | tail -n1)
        body=$(echo "$response" | head -n -1)

        has_error=$(echo "$body" | jq -r 'has("error")')
        has_message=$(echo "$body" | jq -r 'has("message")')

        if [ "$http_code" -eq 201 ]; then
            new_id=$(echo "$body" | jq -r '.id')
            echo "$PET_CREATED_LABEL: ID $new_id, ${NAME_LABEL}: $NEW_PET_NAME"
            break
        elif [ "$http_code" -eq 400 ] && [ "$has_error" = "true" ]; then
            echo "$PET_CREATE_ERROR_LABEL"
            echo "$body" | jq -r '.error'
            read -rp "$PRESS_ENTER_LABEL" _
        elif [ "$http_code" -eq 200 ] && [ "$has_message" = "true" ]; then
            echo "$body" | jq -r '.message'
            break
        else
            echo "$PET_CREATE_ERROR_LABEL"
            echo "$body"
            read -rp "$PRESS_ENTER_LABEL" _
        fi
    done
}




function pet_menu() {
    logo
    echo $API_KEY
    while true; do
        echo
        print_pets
        printf "$SELECT_PET_LABEL\n\n"
        echo "  new  - $CREATE_NEW_PET_LABEL"
        printf "  exit - $EXIT_PET_MENU_LABEL\n\n"
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
            printf '\n%s\n' "$pet_status"

            if echo "$response" | jq -e '.message' > /dev/null 2>&1; then
                echo "$(echo "$response" | jq -r '.message')"
            fi

            printf '%s\n\n' "$WHAT_TO_DO_LABEL"
            echo "1) $FEED_LABEL"
            echo "2) $PLAY_LABEL"
            echo "3) $SLEEP_LABEL"
            echo "4) $BATHE_LABEL"
            echo "5) $MEDICATE_LABEL"
            echo "6) $DELETE_LABEL"
            printf '7) %s\n\n' "$BACK_LABEL"
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
                    if [[ "$CONFIRM" == "yes" ]]; then
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
printf '\n%s\n' "$ABOUT_ME"
show_ascii_pet "raccoon"
printf '%s\n' "$output"
read -p "$MAIN_MENU_PROMPT"
}

function main_menu() {
    while true; do
        logo
        printf '\n%s\n' "$MAIN_MENU_HEADER"
        printf "| %-7s Version 1.0.5 %-7s |\n" ""
        printf "| %-29s |\n" ""
        printf "| 1) %b|\n" "$MENU_LOGIN"
        printf "| 2) %b|\n" "$MENU_SETTINGS"
        printf "| 3) %b|\n" "$MENU_LEADERBOARD"
        printf "| 4) %b|\n" "$MENU_ABOUT"
        printf "| 5) %b|\n" "$MENU_EXIT"
        printf "| %-29s |\n" ""
        printf "| \t%b\t\t|\n" "By PucuR"
        printf "| %b\t|\n" "www.github.com/Pucur/CMDGochi"
        printf '%s\n\n' "|_______________________________|"
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
                printf '\n%s\n' "$GOODBYE_LABEL"
                exit 0
                ;;
            *)
                read -p "$INVALID_CHOICE"
                ;;
        esac
    done
}


main_menu
