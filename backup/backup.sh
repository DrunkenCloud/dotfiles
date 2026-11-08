#!/bin/bash
# Encrypted backup of the paths in paths.txt to Google Drive (restic + rclone).
# Runs daily from the systemd user timer backup.timer (only on AC power).
# Run it by hand any time:  ~/dotfiles/backup/backup.sh
#
# Restore (on this or a new laptop, after setting up rclone + the password):
#   restic -r rclone:gdrive:laptop-backup snapshots
#   restic -r rclone:gdrive:laptop-backup restore latest --target ~/restore

set -uo pipefail
export RESTIC_REPOSITORY="rclone:gdrive:laptop-backup"
export RESTIC_PASSWORD_FILE="$HOME/.config/restic/password"
HERE="$(dirname "$(readlink -f "$0")")"

notify() { notify-send -a Backup "$@" 2>/dev/null || true; }

# Offline (or captive portal)? Skip quietly; the timer tries again tomorrow,
# and Persistent=true catches up at the next boot if a day was missed.
if [ "$(nmcli networking connectivity 2>/dev/null)" != "full" ]; then
    echo "No internet connection, skipping backup."
    exit 0
fi

cd "$HOME" || exit 1
restic backup \
    --files-from "$HERE/paths.txt" \
    --exclude-file "$HERE/excludes.txt" \
    --tag auto
rc=$?
# restic exit 3 = some files couldn't be read (e.g. a file changed mid-backup):
# the snapshot is still saved, so warn but don't treat it as a total failure.
if [ $rc -ne 0 ] && [ $rc -ne 3 ]; then
    notify -u critical "Backup failed" "See: journalctl --user -u backup"
    exit 1
fi
[ $rc -eq 3 ] && notify "Backup finished with warnings" "Some files couldn't be read. See: journalctl --user -u backup"

# Keep 7 daily, 4 weekly and 6 monthly versions; delete older ones.
restic forget --tag auto --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune \
    || notify "Backup cleanup failed" "The backup itself succeeded."
