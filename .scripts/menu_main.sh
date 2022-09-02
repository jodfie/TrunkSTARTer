#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

menu_main() {
    local MAINOPTS=()
    MAINOPTS+=("Configuration " "Setup and start applications")
    MAINOPTS+=("Install Dependencies " "Install required components")
    MAINOPTS+=("Install AirSpy Drivers " "Install required AirSpy Drivers")
    MAINOPTS+=("Update TrunkSTARTer " "Get the latest version of TrunkSTARTer")
    MAINOPTS+=("Prune Docker System " "Remove all unused containers, networks, volumes, images and build cache")

    local MAINCHOICE
    if [[ ${CI-} == true ]]; then
        MAINCHOICE="Cancel"
    else
        MAINCHOICE=$(whiptail --fb --clear --title "TrunkSTARTer" --cancel-button "Exit" --menu "What would you like to do?" 0 0 0 "${MAINOPTS[@]}" 3>&1 1>&2 2>&3 || echo "Cancel")
    fi

    case "${MAINCHOICE}" in
        "Configuration ")
            run_script 'menu_config' || run_script 'menu_main'
            ;;
        "Install Dependencies ")
            run_script 'run_install' || run_script 'menu_main'
            ;;
        "Install AirSpy Drivers ")
            run_script 'run_airspy' || run_script 'menu_main'
            ;;
        "Update TrunkSTARTer ")
            run_script 'update_self' || run_script 'menu_main'
            ;;
        "Prune Docker System ")
            run_script 'docker_prune' || run_script 'menu_main'
            ;;
        "Cancel")
            info "Exiting TrunkSTARTer."
            return
            ;;
        *)
            error "Invalid Option"
            ;;
    esac
}

test_menu_main() {
    # run_script 'menu_main'
    warn "CI does not test menu_main."
}
