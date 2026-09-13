#!/usr/bin/env bash
set -euo pipefail

# Run only in a disposable Ubuntu container; this test changes /etc and installed packages.
[[ -f /.dockerenv && $EUID == 0 ]] || { echo 'Run this test in a disposable Ubuntu container.' >&2; exit 1; }
repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
# shellcheck disable=SC1091
source "$repo_dir/install.sh"
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

# Keep the destructive-conflict checks offline, with real APT parsing and dpkg operations.
curl() {
  if [[ "$*" == *api.github.com* ]]; then
    printf '{"tag_name":"1.0"}\n'
  else
    local destination=${!#}
    cp "$ROS_INSTALL_TEST_DIR/source.deb" "$destination"
  fi
}
run_as_root() {
  case "$1" in
    apt-get) command apt-get --print-uris update >/dev/null ;;
    env)
      case "${!#}" in
        *.deb) dpkg --unpack "${!#}" >/dev/null ;;
        *) : ;; # Bootstrap dependencies are unnecessary for these offline checks.
      esac ;;
    *) fail "unexpected privileged command: $*" ;;
  esac
}

case "${1:-all}" in
  source-package)
    temporary_directory=$(mktemp -d)
    trap cleanup EXIT
    configure_apt_source_package current noble "$temporary_directory"
    ;;
  package-conflict)
    read_ubuntu() { printf 'ubuntu\tlucid\n'; }
    ubuntu_has_universe() { return 0; }
    configure_snapshot_repository() { :; }
    resolve_package() { printf '%s/conflict.deb\n' "$ROS_INSTALL_TEST_DIR"; }
    apt-cache() { return 0; }
    run_as_root() {
      if [[ "$1" != apt-get ]]; then "$@"; fi
    }
    main boxturtle base
    ;;
  all)
    ROS_INSTALL_TEST_DIR=$(mktemp -d)
    export ROS_INSTALL_TEST_DIR
    trap 'rm -rf -- "$ROS_INSTALL_TEST_DIR"' EXIT
    mkdir -p "$ROS_INSTALL_TEST_DIR/package/DEBIAN" \
      "$ROS_INSTALL_TEST_DIR/package/etc/apt/sources.list.d" \
      "$ROS_INSTALL_TEST_DIR/package/usr/share/ros-apt-source"
    cat > "$ROS_INSTALL_TEST_DIR/package/DEBIAN/control" <<'EOF'
Package: ros2-apt-source
Version: 1.0
Architecture: all
Maintainer: Installer Test <test@example.invalid>
Description: Offline repository fixture
EOF
    cat > "$ROS_INSTALL_TEST_DIR/package/usr/share/ros-apt-source/ros2.sources" <<'EOF'
Types: deb
URIs: http://packages.ros.org/ros2/ubuntu
Suites: noble
Components: main
Signed-By: /usr/share/keyrings/ros2-archive-keyring.gpg
EOF
    ln -s /usr/share/ros-apt-source/ros2.sources \
      "$ROS_INSTALL_TEST_DIR/package/etc/apt/sources.list.d/ros2.sources"
    dpkg-deb --build "$ROS_INSTALL_TEST_DIR/package" "$ROS_INSTALL_TEST_DIR/source.deb" >/dev/null

    printf 'deb [signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu noble main\n' \
      > /etc/apt/sources.list.d/legacy-ros2.list
    cp /etc/apt/sources.list.d/legacy-ros2.list "$ROS_INSTALL_TEST_DIR/legacy-ros2.list"
    if output=$(bash "$0" source-package 2>&1); then fail 'conflicting repository was accepted'; fi
    [[ "$output" == *'Conflicting values'* ]] || fail "unexpected error: $output"
    cmp /etc/apt/sources.list.d/legacy-ros2.list "$ROS_INSTALL_TEST_DIR/legacy-ros2.list"
    [[ ! -e /etc/apt/sources.list.d/ros2.sources ]] || fail 'conflicting source was installed'
    command apt-get --print-uris update >/dev/null
    printf 'PASS: source conflict leaves existing APT configuration usable\n'

    rm /etc/apt/sources.list.d/legacy-ros2.list
    bash "$0" source-package
    bash "$0" source-package
    command apt-get --print-uris update >/dev/null
    printf 'PASS: fresh and repeated repository configuration\n'

    mkdir -p "$ROS_INSTALL_TEST_DIR/conflict/DEBIAN"
    cat > "$ROS_INSTALL_TEST_DIR/conflict/DEBIAN/control" <<'EOF'
Package: ros-installer-test-conflict
Version: 1.0
Architecture: all
Maintainer: Installer Test <test@example.invalid>
Conflicts: ros2-apt-source
Description: Offline package removal fixture
EOF
    dpkg-deb --build "$ROS_INSTALL_TEST_DIR/conflict" "$ROS_INSTALL_TEST_DIR/conflict.deb" >/dev/null
    if output=$(bash "$0" package-conflict 2>&1); then fail 'installation removed an existing package'; fi
    [[ "$output" == *'Packages need to be removed'* ]] || fail "unexpected package conflict error: $output"
    dpkg-query -W ros2-apt-source >/dev/null || fail 'existing package was removed'
    printf 'PASS: package conflicts cannot remove existing packages\n'

    printf 'DISTRIB_ID=Ubuntu\nDISTRIB_CODENAME=trusty\n' > /etc/lsb-release
    printf 'ID=ubuntu\n' > /etc/os-release
    [[ $(read_ubuntu) == $'ubuntu\ttrusty' ]] || fail 'missing codename must fall back to lsb-release'
    printf 'ID=debian\n' > /etc/os-release
    IFS=$'\t' read -r os_id os_codename < <(read_ubuntu)
    validate_ubuntu trusty "$os_id" "$os_codename" && fail 'LSB fallback must not disguise a non-Ubuntu host'
    printf 'ID=ubuntu\nVERSION_CODENAME=noble\n' > /etc/os-release
    [[ $(read_ubuntu) == $'ubuntu\tnoble' ]] || fail 'os-release codename must take precedence'
    printf 'PASS: Ubuntu codename fallback preserves OS identity and precedence\n'
    ;;
  *) fail "unknown test: $1" ;;
esac
