#!/usr/bin/env bash
set -u -o pipefail

curl='/usr/bin/curl --progress-bar -fLo'
fontcache='/usr/bin/fc-cache -vf'
version="${1:-v3.1.0}"

getNerd() {
	local font_name="${1}";
	local font_type="${2}";
	local font_file="${font_type#*/}";
	local font_tag="${version}";
	local font_url="https://github.com/ryanoasis/nerd-fonts/raw/${font_tag}/patched-fonts/${font_name}/${font_type}";
	local font_path="${HOME}/.local/share/fonts/${font_file}";

	printf "Fetching %s ...\n" "${font_file}";

	if [[ -f "${font_path}" ]]; then
		printf "[!!] Found %s, updating instead!\n" "${font_file}";
	fi
	
	${curl} "${font_path}" "${font_url}";
	if [[ ${?} -ne 0 ]]; then
		printf "[!!] Error when pull %s\n" "${font_name}";
	fi
}

declare -A nerd_fonts=(
	[Regular-Cousine]="Regular/CousineNerdFont-Regular.ttf"
	[Bold-Cousine]="Bold/CousineNerdFont-Bold.ttf"
	[Italic-Cousine]="Italic/CousineNerdFont-Italic.ttf"
	[Regular-FiraCode]="Regular/FiraCodeNerdFont-Regular.ttf"
	[Bold-FiraCode]="Bold/FiraCodeNerdFont-Bold.ttf"
	[Light-FiraCode]="Light/FiraCodeNerdFont-Light.ttf"
	[Regular-Hermit]="Regular/HurmitNerdFont-Regular.otf"
	[Bold-Hermit]="Bold/HurmitNerdFont-Bold.otf"
	[Italic-Hermit]="Italic/HurmitNerdFont-Italic.otf"
	[Light-Hermit]="Light/HurmitNerdFont-Light.otf"
	[Regular-Iosevka]="Regular/IosevkaNerdFont-Regular.ttf"
	[Bold-Iosevka]="Bold/IosevkaNerdFont-Bold.ttf"
	[Italic-Iosevka]="Italic/IosevkaNerdFont-Italic.ttf"
	[Light-Iosevka]="Light/IosevkaNerdFont-Light.ttf"
)

printf "Nerd Font Source: https://github.com/ryanoasis/nerd-fonts\n"

for font in "${!nerd_fonts[@]}"; do
	getNerd "${font#*-}" "${nerd_fonts[${font}]}"
done

printf "Scan font directory ...\n"

${fontcache} "~/.local/share/fonts/"

unset nerd_fonts[@] font version curl
