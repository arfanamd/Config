#!/usr/bin/env bash

_gpg2="/usr/bin/gpg2"
_usid="<:redacted:>"
_keid="<:redacted:>"

_dir="${HOME}/.2fa"
_put="${1}"
_key="${_dir}/${_put}/.key"
_gen="${_key}.gpg"

# failsafe
if [[ "${1}" == "" ]]; then
	echo "Usage: $(basename ${0})<service>"
	exit 0
elif [[ ! -f "${_key}" ]]; then
	echo "Error: file doesn't exist."
	exit 1
elif [[ -f "${_gen}" ]]; then
	echo "Error: file \"${_gen}\" exist."
	exit ${?}
fi

# main
${_gpg2} -u "${_keid}" -r "${_usid}" --encrypt "${_key}" && rm -i "${_key}"

