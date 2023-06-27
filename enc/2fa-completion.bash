#!/data/data/com.termux/files/usr/bin/env bash

__2faDecryptKey() {
	local services
	services=$(find "${HOME}/.2fa" -type d -printf "%f " | sed 's@.2fa@@')
	complete -W "${services}" dec.key.sh
}
complete -F __2faDecryptKey dec.key.sh
