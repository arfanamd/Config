#!/usr/bin/env bash

_gpg2="/usr/bin/gpg2"
_oath="/usr/bin/oathtool"

_usid="<:redacted:>"
_keid="<:redacted:>"

_dir="${HOME}/.2fa"
_put="${1}"
_key="${_dir}/${_put}/.key"
_gen="${_key}.gpg"

# failsafe
if [[ "${1}" == "" ]]; then
	echo "Usage: $(basename ${0}) <service>"
	exit 0
elif [[ ! -f "${_gen}" ]]; then
	echo "Error: file \"$_gen\" doesn't exist"
	exit 1
fi

# main
_totp=$(${_gpg2} --quiet -u "${_keid}" -r "${_usid}" --decrypt "${_gen}")
_code=$(${_oath} -b --totp "${_totp}")

echo -e "You're code for \e[1;38;2;119;189;253m${_put/\/}\e[0m is ..."
echo -e "\t\e[1m${_code}\e[0m"

[[ -f "${_key}" ]] && echo "Warning: plain text \"${_key}\" file found"
exit ${?}
