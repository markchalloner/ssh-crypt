#!/usr/bin/env bash

declare -r DIR_DATA="${HOME}/.ssh-crypt"

function echo_err()
{
    printf "%s\n" "${*}" >&2
}

# Checks argument value if valid.
function arg_value()
{
    if [ -z "${1}" ] || [ "${1:0}" == "-" ]
    then
        return 1
    fi
    echo "${1}"
}

# Checks variable value is valid.
function var_value()
{
    if [ -z "${1}" ] || [ "${1}" == "" ]
    then
        return 1
    fi
    echo "${1}"
}

function read_input_single()
{
    local var="${1}"; shift
    local name="${1}"; shift
    local input

    var_value "${var}" && return 1

    read ${@} -p "Enter the ${name}: " input
    echo "${input}"
}

function read_input_multi()
{
    local var="${1}"; shift
    local name="${1}"; shift
    local input line

    var_value "${var}" && return 1

    # Use read to prompt the first time.
    read -p "Enter the ${name} (followed by an empty line): "$'\n' input
    while :
    do
        read line
        [ "${line}" == "" ] &&
            break
        input="${input}"$'\n'"${line}"
    done
    echo "${input}"
}

function pk_save_file
{
    local name="${1}"; shift
    local pk_pem="${1}"; shift
    local file

    if [ "${name}" != "" ]
    then
        file="${DIR_DATA}/${name}.pem"
        mkdir -p "${DIR_DATA}"
        echo "${pk_pem}" > "${file}"
    fi
}

function pk_load_file
{
    local name="${1}"; shift
    local file="${DIR_DATA}/${name}.pem"
    local use_cached

    if [ ! -f "${file}" ]
    then
        return 1
    fi

    read -p "Cached public key found. Would you like to use this (Y/n): " use_cached
    while :
    do
        [ "${use_cached}" == "" ] &&
            use_cached=1 &&
            break
        grep -iq "^y\(es\)\?\|1\|true$" <<< "${use_cached}" &&
            use_cached=1 &&
            break
        grep -iq "n\(o\)\?\|0\|false$" <<< "${use_cached}" &&
            use_cached=0 &&
            break
        read -p "Please enter y or n: " use_cached
    done

    if [ ${use_cached} -eq 0 ]
    then
        return 1
    fi

    cat "${file}"
}

function pk_normalise
{
    local pk_content="${1}"; shift

    if grep -q '^-----BEGIN PUBLIC KEY-----' <<< "${pk_content}"
    then
        echo "${pk_content}"
        return
    fi

    if grep -q '^ssh-rsa' <<< "${pk_content}"
    then
        ssh-keygen -f <(echo "${pk_content}") -e -m PKCS8
        return
    fi
}

function pk_content
{
    local name="${1}"; shift
    local pk_file="${1}"; shift
    local pk_content=""

    if [ -n "${pk_file}" ] && [ -f "${pk_file}" ]
    then
        pk_content="$(<"${pk_file}")"
    fi

    if [ "${pk_content}" == "" ] && [ "${name}" != "" ]
    then
        pk_content=$(pk_load_file "${name}")
    fi

    read_input_multi "${pk_content}" "public key"
}

function text_content
{
    local text_file="${1}"; shift
    local text_content;

    if [ -n "${text_file}" ] && [ -f "${text_file}" ]
    then
        text_content="$(<"${text_file}")"
    fi

    if [ "${text_content}" == "" ]
    then
        read -t 1 text_content;
    fi

    read_input_multi "${text_content}" "text to encrypt"
}

function encrypt
{
    local pk_content="${1}"; shift
    local text_content="${1}"; shift
    local output_file="${1}"; shift
    local text_encrypted=$(
        openssl rsautl -encrypt -pubin -ssl -inkey <(echo "${pk_content}") <<< "${text_content}" |
            base64
    )

    if [ "${output_file}" == "" ]
    then
        echo "${text_encrypted}"
    else
        echo "${text_encrypted}" > ${output_file}
        echo_err "Encrypted text saved to: ${output_file}"
    fi
}

function decrypt_command
{
    local output_file="${1}"; shift
    local command_openssl="openssl rsautl -decrypt -inkey ~/.ssh/id_rsa"
    local command instructions

    if [ "${output_file}" == "" ]
    then
        command="{ base64 -D | ${command_openssl} ; } <<< \${encrypted_text}"
    else
        command="base64 -D -i $(basename ${output_file}) | ${command_openssl}"
    fi
    instructions="Decrypt with: ${command}"

    echo "${instructions}"
}

function copy_clipboard
{
    local command_clip=""
    local count=0

    # Determine clipboard command.
    for command in "pbcopy -Prefer txt" "xclip -selection c" "clip"
    do
        type "${command%% *}" &> /dev/null &&
            command_clip="${command}" &&
            break
    done

    if [ "${command_clip}" != "" ]
    then
        for content in "${@}"
        do
            echo "${content}" | ${command_clip}
            # Sleep to allow content to register in the clipboard.
            sleep 1
        done
    fi
}

function main
{
    local decrypt_instructions
    local name
    local output_file
    local public_key_content
    local public_key_file
    local text_content
    local text_encrypted
    local text_file

    # Parse arguments
    while :
    do
        case "${1}" in
            -i|--input-file)
                text_file=$(arg_value "${2}") &&
                    shift
                ;;
            -n|--name)
                name=$(arg_value "${2}") &&
                    shift
                ;;
            -o|--output-file)
                output_file=$(arg_value "${2}") &&
                    shift
                ;;
            -p|--public-key-file)
                public_key_file=$(arg_value "${2}") &&
                    shift
                ;;
            -r|--readme)
                readme
                break
                ;;
            -h|--help)
                usage
                break
                ;;
            --)
                break
                ;;
            -?*)
                usage
                break
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    name="$(read_input_single "${name}" "user's name")"

    if [ "${name}" == "" ]
    then
        echo_err "Warning: No name supplied. Application will not cache public key."
    fi

    public_key_content="$(pk_normalise "$(pk_content "${name}" "${public_key_file}")")"
    text_content="$(text_content "${text_file}")"

    pk_save_file "${name}" "${public_key_content}"

    text_encrypted="$(encrypt "${public_key_content}" "${text_content}" "${output_file}")"
    decrypt_instructions="$(decrypt_command "${output_file}")"

    [ "${text_encrypted}" != "" ] && echo "${text_encrypted}"
    echo_err "${decrypt_instructions}"

    copy_clipboard "${decrypt_instructions}" "${text_encrypted}" &
}

main "${@}"
