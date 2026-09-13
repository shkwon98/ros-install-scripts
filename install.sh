#!/usr/bin/env bash
set -Eeuo pipefail

# Target resolution
resolve_distribution() {
  case "$1" in
    boxturtle|cturtle|diamondback|electric) printf 'ros1\tlucid\teol\tsnapshot\n' ;;
    fuerte|groovy|hydro) printf 'ros1\tprecise\teol\tsnapshot\n' ;;
    indigo|jade) printf 'ros1\ttrusty\teol\tsnapshot\n' ;;
    kinetic|lunar) printf 'ros1\txenial\teol\tsnapshot\n' ;;
    melodic) printf 'ros1\tbionic\teol\tsnapshot\n' ;;
    noetic) printf 'ros1\tfocal\teol\tsnapshot\n' ;;
    ardent) printf 'ros2\txenial\teol\tsnapshot\n' ;;
    bouncy|crystal|dashing|eloquent) printf 'ros2\tbionic\teol\tsnapshot\n' ;;
    foxy|galactic) printf 'ros2\tfocal\teol\tsnapshot\n' ;;
    humble) printf 'ros2\tjammy\tactive\tcurrent\n' ;;
    iron) printf 'ros2\tjammy\teol\tsnapshot\n' ;;
    jazzy|kilted) printf 'ros2\tnoble\tactive\tcurrent\n' ;;
    lyrical) printf 'ros2\tresolute\tactive\tcurrent\n' ;;
    rolling) printf 'ros2\tresolute\trolling\ttesting\n' ;;
    *) return 1 ;;
  esac
}

resolve_package() {
  local distro=$1 generation=$2 variant=$3 suffix
  [[ "$variant" == base || "$variant" == desktop ]] || return 1

  case "$distro:$variant" in
    boxturtle:base) printf 'ros-boxturtle-base\n'; return ;;
    boxturtle:desktop) return 1 ;;
    cturtle:base) printf 'ros-cturtle-base\n'; return ;;
    cturtle:desktop) printf 'ros-cturtle-all\n'; return ;;
    fuerte:base) printf 'ros-fuerte-ros-comm\n'; return ;;
  esac

  if [[ "$variant" == base ]]; then
    suffix=ros-base
  elif [[ "$generation" == ros1 ]]; then
    suffix=desktop-full
  else
    suffix=desktop
  fi

  printf 'ros-%s-%s\n' "$distro" "$suffix"
}

resolve_target() {
  local distro=$1 variant=$2 generation codename lifecycle repository package

  if ! IFS=$'\t' read -r generation codename lifecycle repository < <(resolve_distribution "$distro"); then
    return 1
  fi
  if ! package=$(resolve_package "$distro" "$generation" "$variant"); then
    return 1
  fi

  printf '%s\t%s\t%s\t%s\t%s\n' "$generation" "$codename" "$lifecycle" "$repository" "$package"
}

# Host validation
validate_ubuntu() {
  local expected=$1 actual_id=${2,,} actual_codename=$3
  [[ "$actual_id" == ubuntu && "$actual_codename" == "$expected" ]]
}

read_ubuntu() {
  local ID='' UBUNTU_CODENAME='' VERSION_CODENAME='' DISTRIB_ID='' DISTRIB_CODENAME=''
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
  elif [[ ! -r /etc/lsb-release ]]; then
    return 1
  fi
  if [[ -z "${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}" && -r /etc/lsb-release ]]; then
    # shellcheck disable=SC1091
    source /etc/lsb-release
  fi
  printf '%s\t%s\n' "${ID:-${DISTRIB_ID:-}}" \
    "${UBUNTU_CODENAME:-${VERSION_CODENAME:-${DISTRIB_CODENAME:-}}}"
}

sources_include_universe() {
  local expected=$1
  shift
  awk -v expected="$expected" '
    function has_token(value, wanted, words, count, field) {
      count = split(value, words, /[ \t\r\f\v]+/)
      for (field = 1; field <= count; field++)
        if (words[field] == wanted) return 1
      return 0
    }
    function finish_stanza(field) {
      if (deb822 && tolower(fields["enabled"]) != "no" && has_token(fields["types"], "deb") &&
          has_token(fields["suites"], expected) && has_token(fields["components"], "universe")) found = 1
      for (field in fields) delete fields[field]
      deb822 = 0
      key = ""
    }
    FNR == 1 && NR != 1 { finish_stanza() }
    /^[ \t\r\f\v]*$/ { finish_stanza(); next }
    /^[ \t\r\f\v]*#/ { next }
    {
      line = $0
      sub(/[ \t\r\f\v]*#.*/, "", line)
      continuation = deb822 && line ~ /^[ \t]/
      sub(/^[ \t\r\f\v]+/, "", line)
      sub(/[ \t\r\f\v]+$/, "", line)
      if (continuation) {
        fields[key] = fields[key] == "" ? line : fields[key] " " line
        next
      }
      count = split(line, words, /[ \t\r\f\v]+/)
      if (words[1] == "deb") {
        if (has_token(line, expected) && has_token(line, "universe")) found = 1
        next
      }
      separator = index(line, ":")
      if (separator) {
        key = tolower(substr(line, 1, separator - 1))
        value = substr(line, separator + 1)
        sub(/^[ \t\r\f\v]+/, "", value)
        deb822 = 1
        fields[key] = value
      }
    }
    END { finish_stanza(); exit !found }
  ' "$@"
}

ubuntu_has_universe() {
  local codename=$1 source_file
  local -a apt_sources=()

  for source_file in /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
    if [[ -r "$source_file" ]]; then
      apt_sources+=("$source_file")
    fi
  done

  ((${#apt_sources[@]} > 0)) && sources_include_universe "$codename" "${apt_sources[@]}"
}

# Command helpers
die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

run_as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    command -v sudo >/dev/null 2>&1 || die 'sudo is required when not running as root'
    sudo "$@"
  fi
}

temporary_directory=

cleanup() {
  if [[ -n "${temporary_directory:-}" && -d "$temporary_directory" ]]; then
    rm -rf -- "$temporary_directory"
  fi
}

# Repository configuration
SNAPSHOT_KEY_FINGERPRINT=4B63CF8FDE49746E98FA01DDAD19BAB3CBF125EA
SNAPSHOT_KEY_URL="https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x$SNAPSHOT_KEY_FINGERPRINT"

snapshot_key_is_trusted() {
  local fingerprints
  fingerprints=$(awk -F: '
    $1 == "pub" { primary = 1; next }
    primary && $1 == "fpr" { print $10; primary = 0 }
  ')
  [[ "$fingerprints" == "$SNAPSHOT_KEY_FINGERPRINT" ]]
}

configure_snapshot_repository() {
  local distro=$1 codename=$2 temp_dir=$3
  local key_url=$SNAPSHOT_KEY_URL
  local armored_key="$temp_dir/ros-snapshot.asc"
  local keyring="$temp_dir/ros-snapshot.gpg"
  # Lucid lacks modern TLS; the pinned fingerprint authenticates the public key.
  if [[ "$codename" == lucid ]]; then
    key_url=${key_url/https:/http:}
  fi
  run_as_root apt-get update
  run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl gnupg
  curl -fsSL "$key_url" -o "$armored_key"
  gpg --batch --yes --dearmor --output "$keyring" --homedir "$temp_dir" "$armored_key"
  gpg --batch --no-default-keyring --keyring "$keyring" --homedir "$temp_dir" --with-colons --fingerprint |
    snapshot_key_is_trusted || die 'downloaded ROS snapshot key has an unexpected fingerprint'
  run_as_root install -d -m 0755 /etc/apt/trusted.gpg.d
  run_as_root install -m 0644 "$keyring" /etc/apt/trusted.gpg.d/ros-snapshot.gpg
  printf 'deb http://snapshots.ros.org/%s/final/ubuntu %s main\n' \
    "$distro" "$codename" > "$temp_dir/ros-snapshot.list"
  run_as_root install -m 0644 "$temp_dir/ros-snapshot.list" "/etc/apt/sources.list.d/ros-$distro-snapshot.list"
}

configure_apt_source_package() {
  local repository=$1 codename=$2 temp_dir=$3 source_package version asset url source_file
  source_package=ros2-apt-source
  if [[ "$repository" == testing ]]; then
    source_package=ros2-testing-apt-source
  fi

  run_as_root apt-get update
  run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl python3
  version=$(curl -fsSL https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest |
    python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"])')
  asset="${source_package}_${version}.${codename}_all.deb"
  url="https://github.com/ros-infrastructure/ros-apt-source/releases/download/${version}/${asset}"
  curl -fL "$url" -o "$temp_dir/$asset"

  # Let APT parse the proposed configuration before dpkg changes any live sources.
  dpkg-deb --extract "$temp_dir/$asset" "$temp_dir/source-package"
  mkdir -p "$temp_dir/sources.list.d"
  for source_file in /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
    if [[ -e "$source_file" ]]; then
      cp -L -- "$source_file" "$temp_dir/sources.list.d/"
    fi
  done
  cp "$temp_dir/source-package/usr/share/ros-apt-source/${source_package%-apt-source}.sources" \
    "$temp_dir/sources.list.d/ros2.sources"
  if ! apt-get -o "Dir::Etc::sourceparts=$temp_dir/sources.list.d" --print-uris update >/dev/null; then
    die 'ROS source configuration conflicts with existing APT settings; review /etc/apt/sources.list and /etc/apt/sources.list.d before retrying. Repository settings were not changed.'
  fi

  run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$temp_dir/$asset"
}

main() {
  if [[ $# -ne 2 ]]; then
    die 'usage: ./install.sh <distribution> <base|desktop>'
  fi

  local distro=$1 variant=$2
  local generation codename lifecycle repository package
  local os_id os_codename setup_file

  if ! IFS=$'\t' read -r generation codename lifecycle repository package \
    < <(resolve_target "$distro" "$variant"); then
    die "unsupported target: $distro $variant"
  fi
  if ! IFS=$'\t' read -r os_id os_codename < <(read_ubuntu); then
    die 'could not identify Ubuntu'
  fi
  if ! validate_ubuntu "$codename" "$os_id" "$os_codename"; then
    die "$distro requires Ubuntu $codename; found ${os_id:-unknown} ${os_codename:-unknown}"
  fi
  if ! ubuntu_has_universe "$codename"; then
    die 'Ubuntu Universe is required; enable it in the host apt sources first'
  fi

  if [[ "$lifecycle" == eol ]]; then
    printf 'warning: ROS %s is EOL and will be installed from its frozen final snapshot.\n' \
      "$distro" >&2
  fi

  temporary_directory=$(mktemp -d)
  trap cleanup EXIT

  if [[ "$repository" == snapshot ]]; then
    configure_snapshot_repository "$distro" "$codename" "$temporary_directory"
  else
    configure_apt_source_package "$repository" "$codename" "$temporary_directory"
  fi

  run_as_root apt-get update
  if ! apt-cache show "$package" >/dev/null 2>&1; then
    die "$package is unavailable for $(dpkg --print-architecture)"
  fi
  run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-remove "$package"
  setup_file="/opt/ros/$distro/setup.bash"
  if [[ "$distro" == boxturtle ]]; then
    setup_file="/opt/ros/$distro/setup.sh"
  fi
  if [[ ! -r "$setup_file" ]]; then
    die "installation completed without $setup_file"
  fi
  printf 'Installed %s. Run:\n  source %s\n' "$package" "$setup_file"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
