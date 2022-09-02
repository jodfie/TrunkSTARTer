#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

menu_airspy() {
    local AIRSPYOPTS=()
    AIRSPYOPTS+=("Install AirSpy Drivers" "This installs the AirSpy Drivers and Spy Server")

    local AIRSPYCHOICE
    if [[ ${CI-} == true ]]; then
        AIRSPYCHOICE="Cancel"
    else
        AIRSPYCHOICE=$(whiptail --fb --clear --title "TrunkSTARTer" --menu "What would you like to do?" 0 0 0 "${AIRSPYOPTS[@]}" 3>&1 1>&2 2>&3 || echo "Cancel")
    fi

    case "${AIRSPYCHOICE}" in
        "Install Airspy Drivers")
            run_script 'update_system'
            run_script 'get_airspy'
            ;;
        "Cancel")
            info "Returning to Main Menu."
            return 1
            ;;
        *)
            error "Invalid Option"
            ;;
    esac
}

test_menu_airspy() {
    # run_script 'menu_AIRSPY'
    warn "CI does not test menu_airspy."
}
