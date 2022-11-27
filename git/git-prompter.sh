# Unofficial Git prompt specific for Bash.
# ----------------------------------------
# This version is much simpler, much readable, much faster than the
# official version of git-prompt.sh provided by Git developer.
# 
# Add the __git_promptPS1 to your PS1 variable and then when you're
# inside a Git repository -- whether it's bare or working tree --,
# you will get the repository information in your bash prompt.
#
# Some icon information:
# (#) means your current working tree doesn't have any tracked files.
# (=) means your current working tree is clean (no difference with
#     upstream), if this icon not showing up that means your current
#     working tree doesn't have any remote upstream.
# (+) means you have some staged files that ready to be commited.
# (*) means you have some unstaged files.
# ($) means you have some files stashed.
# (→) means your current working tree is ahead of the remote
#     upstream.
# (←) means your current working tree is behind the remote
#     upstream.
# (↔) means your current working tree is divergent from remote
#     upstream.
# (!) shows how many untracked files in your current working tree.

# Read the first line from a file & assign it to a variable.
__git_testRead() {    # 1: file-path, 2: variable
	command test -r "${1}" && IFS=$'\r\n' read "${2}" < "${1}"
}
__git_upStream() {
	# contain "raw-format" status of the repository.
	local commits="$(\
		command git rev-list --count \
		--left-right '@{upstream}...HEAD' 2>&1 | tr '\t' ',' \
	)"
	local indicator

	case ${commits} in
		'fatal:'*)
			indicator='';;  # no upstream
		'0,0')
			indicator='=';; # equal
		'0,'[0-9])
			indicator='→';; # ahead
		[0-9]',0')
			indicator='←';; # behind
		[0-9]','[0-9])
			indicator='↔';; # diverged from upstream
		*)
			indicator='×';; # unknown case is an error
	esac

	command printf -- "${param}"
}
__git_unTrack() {
	# contain list of untracked files.
	local untrack=($(\
		command git ls-files --others --exclude-standard \
		--directory --no-empty-directory --deduplicate \
		--error-unmatch -- ':/*' 2> /dev/null \
	))
	local count=${#untrack[@]}

	[[ ${count} -gt 0 ]] && untrack="!${count}" || untrack=""
	command printf -- "${untrack}"
}
__git_promptPS1() {
	# Only support bash v5 or greater.
	[[ ${BASH_VERSINFO} -ge 5 ]] && shopt -q promptvars || exit

	# contain list of information about the repository.
	local repo_info=($(\
		command git rev-parse \
		--git-dir \
		--is-inside-git-dir \
		--is-bare-repository \
		--is-inside-work-tree \
		--short HEAD 2> /dev/null \
	))
	local repo_len=${#repo_info[@]}

	# $repo_info should have 4 or 5 elements.
	# The $repo_len should be 4 or 5.
	test ${repo_len} -lt 4 -o ${repo_len} -gt 5 && exit

	local status sparse branch tags attrs untrack
	local step total tmp state

	# When we were inside the working tree directory.
	if [[ "${repo_info[3]}" == "true" ]]; then
		# Hide git-prompter if bash.hideIfPwdIgnored is set.
		#test $(command git config --bool bash.hideIfPwdIgnored) && command git check-ignore -q .

		# Show "sparse-checkout" if core.sparseCheckout is set.
		command test $(command git config --bool core.sparseCheckout) && sparse='|SPARSE'

		if [[ -d "${repo_info[0]}/rebase-merge" ]]; then
			__git_testRead "${repo_info[0]}/rebase-merge/msgnum" step
			__git_testRead "${repo_info[0]}/rebase-merge/end" total
			status='|REBASE'

		elif [[ -d "${repo_info[0]}/rebase-apply" ]]; then
			__git_testRead "${repo_info[0]}/rebase-apply/next" step
			__git_testRead "${repo_info[0]}/rebase-apply/last" total

			if [[ -f "${repo_info[0]}/rebase-apply/rebasing" ]]; then
				status='|REBASE'
			elif [[ -f "${repo_info[0]}/rebase-apply/applying" ]]; then
				status='|AM'
			else
				status='|AM/REBASE'
			fi

		elif [[ -f "${repo_info[0]}/MERGE_HEAD" ]]; then
			status='|MERGING'
		elif [[ -f "${repo_info[0]}/CHERRY-PICK-HEAD" ]]; then
			status='|CHRY-PICK'
		elif [[ -f "${repo_info[0]}/REVERT_HEAD" ]]; then
			status='|REVERTING'
		elif [[ -f "${repo_info[0]}/BISECT_LOG" ]]; then
			status='|BISECTING'
		fi

		# Get the current branch name.
		__git_testRead "${repo_info[0]}/HEAD" branch
		branch="${branch##*/}"
		branch="${branch:-${repo_info[4]}}"

		# Get the current tag.
		tags="$(command git describe --tags HEAD 2> /dev/null)"
		tags="${tags:+(${tags})}"

		# Show staged (+) and unstaged (*) info
		state="$(command git diff --no-ext-diff 2> /dev/null)"
		[[ "${state}" != "" ]] && attrs="${attrs}*"

		state="$(command git diff --no-ext-diff --cached 2> /dev/null)"
		[[ "${state}" != "" ]] && tmp="+"

		command test ${repo_len} -eq 4 -a "${tmp}" != "+" && tmp="#"

		attrs="${attrs}${tmp}"

		# Show a '$' sign when some files are stashed.
		tmp="$(command git rev-parse --verify -q refs/stash 2> /dev/null)"
		attrs="${attrs}${tmp:+$}"

		# Get the current untracked files.
		untrack="$(__git_unTrack)"

		# Show diverge information between remote and upstream.
		# (×): error, (↔): diverged from upstream, (←): behind, (→): ahead, (=): equal.
		attrs="${attrs}$(__git_upStream)"

	# When we were inside the bare repository.
	elif [[ "${repo_info[2]}" == "true" ]]; then
		__git_testRead "${repo_info[0]}/HEAD" branch
		branch="${branch##*/}"
		branch="${branch:-${repo_info[4]}}"
		branch="${branch:+BARE:${branch}}"
	fi

	command printf -- " ${branch}${tags:+ ${tags}}${status:+ ${status}}${sparse:+ ${sparse}}${attrs:+ ${attrs}}${untrack:+ ${untrack}}"
}
# vim:ft=bash:ts=2:sw=2
