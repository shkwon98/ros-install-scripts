#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
# shellcheck disable=SC1091
source "$repo_dir/install.sh"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
assert_eq() { [[ "$1" == "$2" ]] || fail "expected '$2', got '$1'"; }

distribution_cases=(
  'boxturtle|ros1|lucid|eol|snapshot'
  'cturtle|ros1|lucid|eol|snapshot'
  'diamondback|ros1|lucid|eol|snapshot'
  'electric|ros1|lucid|eol|snapshot'
  'fuerte|ros1|precise|eol|snapshot'
  'groovy|ros1|precise|eol|snapshot'
  'hydro|ros1|precise|eol|snapshot'
  'indigo|ros1|trusty|eol|snapshot'
  'jade|ros1|trusty|eol|snapshot'
  'kinetic|ros1|xenial|eol|snapshot'
  'lunar|ros1|xenial|eol|snapshot'
  'melodic|ros1|bionic|eol|snapshot'
  'noetic|ros1|focal|eol|snapshot'
  'ardent|ros2|xenial|eol|snapshot'
  'bouncy|ros2|bionic|eol|snapshot'
  'crystal|ros2|bionic|eol|snapshot'
  'dashing|ros2|bionic|eol|snapshot'
  'eloquent|ros2|bionic|eol|snapshot'
  'foxy|ros2|focal|eol|snapshot'
  'galactic|ros2|focal|eol|snapshot'
  'humble|ros2|jammy|active|current'
  'iron|ros2|jammy|eol|snapshot'
  'jazzy|ros2|noble|active|current'
  'kilted|ros2|noble|active|current'
  'lyrical|ros2|resolute|active|current'
  'rolling|ros2|resolute|rolling|testing'
)

for row in "${distribution_cases[@]}"; do
  IFS='|' read -r distro generation codename lifecycle repository <<<"$row"
  actual=$(resolve_distribution "$distro") || fail "could not resolve $distro"
  assert_eq "$actual" "$generation"$'\t'"$codename"$'\t'"$lifecycle"$'\t'"$repository"
done

assert_eq "$(resolve_package boxturtle ros1 base)" 'ros-boxturtle-base'
resolve_package boxturtle ros1 desktop >/dev/null 2>&1 && fail 'Box Turtle desktop must fail'
assert_eq "$(resolve_package cturtle ros1 base)" 'ros-cturtle-base'
assert_eq "$(resolve_package cturtle ros1 desktop)" 'ros-cturtle-all'
assert_eq "$(resolve_package diamondback ros1 base)" 'ros-diamondback-ros-base'
assert_eq "$(resolve_package electric ros1 desktop)" 'ros-electric-desktop-full'
assert_eq "$(resolve_package fuerte ros1 base)" 'ros-fuerte-ros'
assert_eq "$(resolve_package fuerte ros1 desktop)" 'ros-fuerte-desktop-full'

for distro in groovy hydro indigo jade kinetic lunar melodic noetic; do
  assert_eq "$(resolve_package "$distro" ros1 base)" "ros-$distro-ros-base"
  assert_eq "$(resolve_package "$distro" ros1 desktop)" "ros-$distro-desktop-full"
done

for distro in ardent bouncy crystal dashing eloquent foxy galactic humble iron jazzy kilted lyrical rolling; do
  assert_eq "$(resolve_package "$distro" ros2 base)" "ros-$distro-ros-base"
  assert_eq "$(resolve_package "$distro" ros2 desktop)" "ros-$distro-desktop"
done

resolve_distribution unknown >/dev/null 2>&1 && fail 'unknown distribution must fail'
resolve_package noetic ros1 minimal >/dev/null 2>&1 && fail 'unknown variant must fail'
printf 'PASS: target resolution\n'

validate_ubuntu jammy ubuntu jammy || fail 'matching Ubuntu must pass'
validate_ubuntu jammy Ubuntu jammy || fail 'Ubuntu ID comparison must ignore case'
validate_ubuntu jammy ubuntu focal >/dev/null 2>&1 && fail 'wrong codename must fail'
validate_ubuntu jammy debian jammy >/dev/null 2>&1 && fail 'wrong OS must fail'
sources_include_universe noble <(printf 'deb http://archive.ubuntu.com/ubuntu noble main universe\n') ||
  fail 'one-line apt sources must detect Universe'
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

cleanup_test_directory=$(mktemp -d)
temporary_directory=$cleanup_test_directory
cleanup
[[ ! -e "$cleanup_test_directory" ]] || fail 'cleanup must remove the temporary directory'
temporary_directory=
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
printf 'PASS: command validation\n'
