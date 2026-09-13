#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
# shellcheck disable=SC1091
source "$repo_dir/install.sh"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
assert_eq() { [[ "$1" == "$2" ]] || fail "expected '$2', got '$1'"; }

# Cover repository modes and package naming exceptions without duplicating the distro table.
assert_eq "$(resolve_target boxturtle base)" $'ros1\tlucid\teol\tsnapshot\tros-boxturtle-base'
assert_eq "$(resolve_target fuerte base)" $'ros1\tprecise\teol\tsnapshot\tros-fuerte-ros-comm'
assert_eq "$(resolve_target noetic desktop)" $'ros1\tfocal\teol\tsnapshot\tros-noetic-desktop-full'
assert_eq "$(resolve_target iron base)" $'ros2\tjammy\teol\tsnapshot\tros-iron-ros-base'
assert_eq "$(resolve_target jazzy desktop)" $'ros2\tnoble\tactive\tcurrent\tros-jazzy-desktop'
assert_eq "$(resolve_target rolling base)" $'ros2\tresolute\trolling\ttesting\tros-rolling-ros-base'
assert_eq "$(resolve_package cturtle ros1 base)" 'ros-cturtle-base'
assert_eq "$(resolve_package cturtle ros1 desktop)" 'ros-cturtle-all'
assert_eq "$(resolve_package diamondback ros1 base)" 'ros-diamondback-ros-base'
printf 'PASS: target resolution\n'

validate_ubuntu jammy ubuntu jammy || fail 'matching Ubuntu must pass'
validate_ubuntu jammy Ubuntu jammy || fail 'Ubuntu ID comparison must ignore case'
validate_ubuntu jammy ubuntu focal >/dev/null 2>&1 && fail 'wrong codename must fail'
validate_ubuntu jammy debian jammy >/dev/null 2>&1 && fail 'wrong OS must fail'
if [[ -r /etc/lsb-release ]]; then
  (
    # Check the real host files, including older Ubuntu images without a codename in os-release.
    # shellcheck disable=SC1091
    source /etc/lsb-release
    if [[ ${DISTRIB_ID:-} == Ubuntu ]]; then
      IFS=$'\t' read -r os_id os_codename < <(read_ubuntu)
      validate_ubuntu "$DISTRIB_CODENAME" "$os_id" "$os_codename" ||
        fail "host detection lost the Ubuntu codename: $DISTRIB_CODENAME"
    fi
  )
fi
sources_include_universe noble <(printf 'deb http://archive.ubuntu.com/ubuntu noble main universe\n') ||
  fail 'one-line apt sources must detect Universe'
sources_include_universe noble <(printf 'deb\thttp://archive.ubuntu.com/ubuntu noble\fmain\vuniverse\r\n') ||
  fail 'one-line sources must retain whitespace handling on legacy awk'
sources_include_universe noble <(printf 'Types: deb\nSuites: noble noble-updates\nComponents: main restricted universe\n') ||
  fail 'deb822 apt sources must detect Universe'
sources_include_universe noble <(printf '# deb http://archive.ubuntu.com/ubuntu noble universe\ndeb http://archive.ubuntu.com/ubuntu noble main\n') &&
  fail 'commented Universe must not pass'
sources_include_universe noble <(printf 'deb-src http://archive.ubuntu.com/ubuntu noble main universe\n') &&
  fail 'source-only Universe must not pass'
sources_include_universe noble <(printf 'deb http://archive.ubuntu.com/ubuntu noble main # universe\n') &&
  fail 'inline comments must not enable Universe'
sources_include_universe noble <(printf 'Types: deb\nSuites: noble\nComponents: main universe\nEnabled: no\n') &&
  fail 'disabled deb822 Universe must not pass'
sources_include_universe noble <(printf 'deb http://archive.ubuntu.com/ubuntu jammy main universe\n') &&
  fail 'Universe for another Ubuntu suite must not pass'
sources_include_universe noble <(printf 'Types:\n deb\nSuites:\n noble\n noble-updates\nComponents: main\n# continuation after a comment\n\tuniverse\r\n') ||
  fail 'folded deb822 fields must detect Universe'
sources_include_universe noble <(printf 'Types: deb\nSuites: noble\nComponents: main\n universe\nEnabled:\n no\n') &&
  fail 'folded disabled deb822 sources must not pass'
sources_include_universe noble <(printf 'Types: deb\nSuites: noble\nComponents: main\n\nTypes: deb-src\nSuites: noble\nComponents: universe\n') &&
  fail 'deb822 stanzas must not share fields'

valid_snapshot_key=$(printf '%s\n' \
  'pub:-:3072:1:AD19BAB3CBF125EA:1542638189:1811791680::-:::scESC::::::23::0:' \
  'fpr:::::::::4B63CF8FDE49746E98FA01DDAD19BAB3CBF125EA:' \
  'sub:-:3072:1:0000000000000000:1542638189:1811791680:::::e::::::23:' \
  'fpr:::::::::AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA:')
printf '%s\n' "$valid_snapshot_key" | snapshot_key_is_trusted || fail 'expected snapshot key must pass'
printf '%s\n' 'pub:::::::::' 'fpr:::::::::AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA:' |
  snapshot_key_is_trusted && fail 'unexpected snapshot key must fail'
printf '%s\n' "$valid_snapshot_key" \
  'pub:::::::::' 'fpr:::::::::AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA:' |
  snapshot_key_is_trusted && fail 'additional primary key must fail'

printf 'PASS: host and trust validation\n'

assert_main_fails_with() {
  local expected=$1 output
  shift
  if output=$(main "$@" 2>&1); then
    fail "main unexpectedly accepted: $*"
  fi
  [[ "$output" == *"$expected"* ]] || fail "expected error '$expected', got '$output'"
}

assert_main_fails_with 'usage:'
assert_main_fails_with 'usage:' noetic
assert_main_fails_with 'unsupported target:' unknown base
assert_main_fails_with 'unsupported target:' noetic minimal
assert_main_fails_with 'unsupported target:' boxturtle desktop
printf 'PASS: command validation\n'
