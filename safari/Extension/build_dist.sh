#!/bin/sh -e

if [ -z "$PROJECT_DIR" ]; then
  PROJECT_DIR="$(dirname "$0")/.."
fi


EXTENSION_DIR="${PROJECT_DIR}/../extension"


dirty_sources() {
    # Check if the directory is currently tracked by git
    if git -C "${EXTENSION_DIR}" rev-parse &> /dev/null; then
        # We are tracked by git, were there any changes?
        if git diff --quiet "${EXTENSION_DIR}"; then
            # There are no changes, we don't need to rebuild
            return 1
        fi
    fi

    # There are changes, or we don't know if there are changes
    return 0
}

last_build_succeeded() {
    # Check if the previous build completed
    if [ -f "${EXTENSION_DIR}/dist/.built" ]; then
        return 0
    fi
    return 1
}


case "$1" in
    clean)
        rm -Rf "${EXTENSION_DIR}/dist"
        ;;
    ""|build)
        if (last_build_succeeded && ! dirty_sources); then
            echo "No reason to rebuild, have a nice day"
        else
            pushd "${EXTENSION_DIR}"
            rm -f "dist/.built"
            npm run distbuild
            touch "dist/.built"
            popd
        fi
        ;;
    *)
        echo "error: unknown subcommand $1" 1>&2
        exit 1
        ;;
esac
