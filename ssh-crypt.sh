#!/usr/bin/env bash

# Don't declare these readonly to avoid errors when we source self to build the README.
declare PATH_SELF="${0}"
declare FILE_SELF="$(basename ${PATH_SELF})"
declare NAME_SELF=${FILE_SELF%.*}
declare DIR_SELF="$(dirname ${PATH_SELF})"
declare DIR_DATA="${HOME}/.ssh-crypt"

function usage() {
    sed 's/^        //g' <<EOF
        ${NAME_SELF} allows encryption of plain-text using an SSH public key.

        Usage: ${NAME_SELF} [options]

        Options

            -h, --help                      optional: Show this message.
            -n, --name <name>               optional: Unique identifier of user (e.g. firstname.lastname or example@domain.tld)
                                            used to cache the user's public key. If not specified then ${NAME_SELF} will fallback
                                            to asking for it on run.
            -i, --input-file <file>         optional: Path to plain-text file to encrypt. If not specified then ${NAME_SELF} will use
                                            plain-text from stdin or fallback to asking for it when run.
            -o, --output-file <file>        optional: Path to encrypted file. If not specified then ${NAME_SELF} will output the
                                            encrypted text to stdout (and copy it to the clipboard if possible)
            -p, --public-key-file <file>    optional: Path to public key file. If not specified then ${NAME_SELF} will check the
                                            cache for a file matching the \`name\` argument.

        Cache

        Public keys are cached in ${DIR_DATA/${HOME}/~}.

EOF
    exit
}

function readme() {
    sed 's/^        //g' > ${DIR_SELF}/README.md <<EOF
        # SSH Crypt

        $(source ${PATH_SELF} -h |
            sed \
                -e 's/^Usage: /## Usage\'$'\n''\'$'\n''```\'$'\n''/' \
                -e 's/${NAME_SELF}/`${NAME_SELF}`/g'
        )
        \`\`\`

        ## Install/Uninstall
        Use the included make file to install or uninstall

        Install:

        \`\`\`bash
        git clone https://github.com/markchalloner/${NAME_SELF}.git
        cd ${NAME_SELF}
        sudo make install
        \`\`\`

        Uninstall:

        \`\`\`bash
        git clone https://github.com/markchalloner/${NAME_SELF}.git
        cd ${NAME_SELF}
        sudo make uninstall
        \`\`\`

        ## Examples

        Using interactively:

        \`\`\`bash
        \$ ${NAME_SELF}
        Enter the user's name: example@domain.tld
        Cached public key found. Would you like to use this (Y/n): n
        Enter the public key (followed by an empty line):
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/pyZFLExrP+vtGZ5FflHVDKsjzDXaFRqk/gsiF4RJUAOF18v5dSxwIyHx45jpMyfyhTg8FIaxgdpqK3F8ERALfU6Txp4mUEkaI0y04MhSPFwsw2Q45bGIrgpb9f/5L23/DcEue7Y8UkhtG/gAu2EWNyvfAml7ed6Te6/u4aPLCZPix1v4WqvVvVkS9SFJqvJYZqQ+ZnumQbEwA5PEBI7FKmzcqgahafcgSr4I418BjCcF6ZstHKoO+ZQ1bVjA5tPcNIu4jmJ9tSAdaujzPLEwxYA8P9HsxjuV8fXlLcYYMRwgab7lnwt8qEEZOYWO8bWiGHOKTBHYKsFTqiY+WDq9eJb2SsArNjHzbMmuzceg8eDMaFwTKeTGu9K98yAwHNNIkU3T3rUG5Abc99zi6OU2v/n804Z7VBOIl+hsGER2cilN4d9rDzmsO04E/Jw7BIGYfcH7NX92nSW+ZUUjRX8e/Pl2fToO0edntHkoCJzbCkgx1FXZy1XCGRKo+Z1cx5J3z7plAh4L2YQgzKQ/bhI9d/TyqPqh/wl4lkywQZjwq3OaCZ9ufxZ78MSoCtohF21Wa86OtqIYjG8T0z7eZEra7HSPKk+gFzIg/nmfoLkNwlllg4w5qXF2oUvsB59RvpjGmnKvIMK3G7VOv3havKHv/LCNTrm5Mr1T3a/MIrjyYw== example@domain.tld

        Enter the text to encrypt (followed by an empty line):
        foobar

        pBURlPWmROiesciSkV3pDfLEhMZgF2oWSbCGnj/VciRMwJME5e7nIuXnMTcEsQ+VWuttQIYVbgp7p1C6KxhWgvVm8VgaiXqcUQhkKkZNFamRZcZdW928GHfQ++vO9eoOy9u3ZFfULm8HHK9LePAtEi1knhYHy2MHcw/QOTnYXtTgPEY1QjpXIwpBb/zQBz7XSW/2HVBHcklQQ83qcfoGYK0UNM5rMs2G8xXsK/K37h0QfPTOzvgJ1fvGXrV75y6iZDXUJZgsALPRmeG3mYLSjs/au9ppWNu5oG2sXoOHtMtxXK98r/G4yrkQGr6fKTRLAGjepWTfkaqqn1VDCTb3iiiGBoNik4rGD0uoX8JgI+rlTIdoPW9Xa73rQCV9EV0LH6ufiUenCMOBYqyVDcHa/uetbbUMRRGkBb5gU2Ogeec2ALVDcKcayLgcxYifE0BYs1jOSdLOVSxwNE9usDgrhTgoEtX7t6k/CMxILWXs0sOVG4QmwOBdSmSaEqz2LhasATOqgF7UkFh9lNf7Dbks8bkYYe2i+tEWlLCSYA93nNwP09cBLW/jAf+lCJD7EFR6Man7w7KO3ZnE30KWgTMZF+DgwwJ+OmgebHSXQS6X6be5Z9iHdVp1ZZ3Ola+mGyIqJghF0QhE1/wvh27+zGGcqjOHj1iXetIGKaju8/S5Oig=
        Decrypt with SSH key: \`{ openssl base64 -d | openssl rsautl -decrypt -inkey ~/.ssh/id_rsa ; } <<< \${encrypted_text}\`
        Decrypt with Yubikey: \`pkcs11-tool -m RSA-PKCS --decrypt -i <(openssl base64 -d <<< \${encrypted_text})\`
        \`\`\`

        Using command line arguments:

        \`\`\`bash
        \$ ${NAME_SELF} -n example@domain.tld -p ~/.ssh-crypt/example@domain.tld.pem -i plaintext.txt -o secret.enc
        Encrypted text saved to: secret.enc
        Decrypt with SSH key: \`openssl base64 -d -in secret.enc | openssl rsautl -decrypt -inkey ~/.ssh/id_rsa\`
        Decrypt with Yubikey: \`pkcs11-tool -m RSA-PKCS --decrypt -i <(openssl base64 -d -in secret.enc)\`
        \`\`\`

        Using stdin and stdout:

        \`\`\`bash
        \$ ${NAME_SELF} -n example@domain.tld -p ~/.ssh-crypt/example@domain.tld.pem <<< "foobar" > secret.enc
        Decrypt with SSH key: \`{ openssl base64 -d | openssl rsautl -decrypt -inkey ~/.ssh/id_rsa ; } <<< \${encrypted_text}\`
        Decrypt with Yubikey: \`pkcs11-tool -m RSA-PKCS --decrypt -i <(openssl base64 -d <<< \${encrypted_text})\`
        \$ cat secret.enc
        BdRa+z5JfxWvIXdrOugAE1U+VU4YYJEPpM3OgylNgmwhM7HjZPQpFPYmk5GPVE+/Nc5mJM0O5yX88JdvDAkYas72FFuDC/JLDQHZIN/ymaJ50UEzTwKYnffT0maxH4pE963i1P1BHnShyl6ZcOqEmQrWNmHtTr/IkOsB3CCMPqtfTPI1cRiKbtPUsny/5jD3Outx/CuVvYo1mG5KyyHjRlp63W6lWsYCR97YMpKOiVm8DlmZLwjzP/Uf4kfsaKo5fs1Q51vOowUJAu8El09vnLCusgcIwI0401oa1TdpA3ARTAWJ2Nw2Imi39Ks4zcGzoXqLQesjGLCEqUp7CeZCn+0QgOUFeCmemtqEn137XMAvyZrUBI2KWZUBfWkH9GbVzGy05J2MD8x/l4S3Oq3TCph3VWiA88RYzsUMXCr4XxkSqGXfVtDOYLmLYXbXSsYu/eCXDjnEgwPXo4rp/Iriw9w/afKMCf68S+7aF/2E+WsICCuhBDgqCtUW9BWVV0/7qyJbIXHU+mRLZ6Aye2YmfvDT2FmNyhJRkcobxnAT1C1tm4qKcC2pdDH3CBQg+qH3PMmNjAEjf+NQXnpNCGtCdUfQaxMq+3i/Es9Bs0yl2wk1r1sVKmx1BcSLVtGk5FFWRLj1/eRjkLzsEnK7CFsuDeOCD4vxnm6Q/ZylxgDY3e8=
        \`\`\`

        ## Readme
        Generated with:

        \`\`\`bash
        ${NAME_SELF} -r
        \`\`\`
EOF
	exit
}

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
    local command_ssh command_yubikey instructions

    if [ "${output_file}" == "" ]
    then
        command_ssh="{ openssl base64 -d | ${command_openssl} ; } <<< \${encrypted_text}"
        command_yubikey="pkcs11-tool -m RSA-PKCS --decrypt -i <(openssl base64 -d <<< \${encrypted_text})"
    else
        command_ssh="openssl base64 -d -in $(basename "${output_file}") | ${command_openssl}"
        command_yubikey="pkcs11-tool -m RSA-PKCS --decrypt -i <(openssl base64 -d -in $(basename "${output_file}"))"
    fi

    cat <<EOF
Decrypt with SSH key: \`${command_ssh}\`
Decrypt with Yubikey: \`${command_yubikey}\`
EOF
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
