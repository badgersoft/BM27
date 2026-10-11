#!/bin/sh
# Band Manager 27 version numbers: MAJOR.MINOR.PATCH
#
#   MAJOR  big milestones (1.0.0 = the first full release)
#   MINOR  new features or content
#   PATCH  fixes and tweaks (bumped automatically on every commit by the
#          git hook in .githooks, unless the commit already changes it)
#
# The version lives in project.godot (application/config/version) and is
# copied into every export preset. The game shows it on the main menu.
#
#   tools/version.sh                        print the current version
#   tools/version.sh bump patch             fixes and tweaks
#   tools/version.sh bump minor "Summary"   new features (adds a CHANGELOG entry)
#   tools/version.sh bump major "Summary"   a milestone (adds a CHANGELOG entry)
#   tools/version.sh set 1.2.3              set an exact version
#   tools/version.sh install-hooks          turn on the automatic patch bump
#
# Plain POSIX sh, so it runs on Linux, macOS and Git Bash on Windows.

set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

current() {
	sed -n 's/^config\/version="\(.*\)"/\1/p' project.godot
}

## Reads a file on stdin and writes it back with version $1 filled in.
apply() {
	v=$1
	maj=${v%%.*}
	rest=${v#*.}
	min=${rest%%.*}
	pat=${rest#*.}
	code=$((maj * 10000 + min * 100 + pat))
	sed -e "s/^config\/version=\".*\"/config\/version=\"$v\"/" \
		-e "s/^application\/file_version=\".*\"/application\/file_version=\"$v.0\"/" \
		-e "s/^application\/product_version=\".*\"/application\/product_version=\"$v.0\"/" \
		-e "s/^application\/short_version=\".*\"/application\/short_version=\"$v\"/" \
		-e "s/^application\/version=\".*\"/application\/version=\"$v\"/" \
		-e "s/^version\/name=\".*\"/version\/name=\"$v\"/" \
		-e "s/^version\/code=.*/version\/code=$code/"
}

write() {
	for f in project.godot export_presets.cfg; do
		apply "$1" < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
	done
}

next() {
	v=$(current)
	maj=${v%%.*}
	rest=${v#*.}
	min=${rest%%.*}
	pat=${rest#*.}
	case "$1" in
		major) echo "$((maj + 1)).0.0" ;;
		minor) echo "$maj.$((min + 1)).0" ;;
		patch) echo "$maj.$min.$((pat + 1))" ;;
		*) echo "Unknown part '$1' (use major, minor or patch)" >&2; exit 1 ;;
	esac
}

## Adds "## v1.2.0 (date): summary" under the CHANGELOG title.
changelog() {
	[ -f CHANGELOG.md ] || printf '# Changelog\n\n' > CHANGELOG.md
	entry="## v$1 ($(date +%Y-%m-%d))"
	[ -n "$2" ] && entry="$entry: $2"
	awk -v e="$entry" 'NR == 1 { print; print ""; print e; next } { print }' CHANGELOG.md > CHANGELOG.md.tmp
	mv CHANGELOG.md.tmp CHANGELOG.md
}

case "$1" in
	"" | show)
		current
		;;
	bump)
		v=$(next "${2:-patch}")
		write "$v"
		if [ "${2:-patch}" != "patch" ]; then
			changelog "$v" "$3"
		fi
		echo "$v"
		;;
	set)
		case "$2" in
			[0-9]*.[0-9]*.[0-9]*) write "$2"; echo "$2" ;;
			*) echo "Use: tools/version.sh set MAJOR.MINOR.PATCH" >&2; exit 1 ;;
		esac
		;;
	apply)
		# Used by the git hook: filter stdin with version $2.
		apply "$2"
		;;
	install-hooks)
		git config core.hooksPath .githooks
		chmod +x .githooks/* tools/version.sh 2>/dev/null || true
		echo "Hooks on: every commit now gets a new patch number."
		;;
	*)
		sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'
		exit 1
		;;
esac
