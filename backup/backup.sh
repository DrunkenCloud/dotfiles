#!/bin/bash
# Encrypted backup of the paths in paths.txt to MEGA (restic + rclone).
# Runs daily from the systemd user timer backup.timer (only on AC power).
# Run it by hand any time:  ~/dotfiles/backup/backup.sh
#
# Restore (on this or a new laptop, after setting up rclone + the password):
#   restic -r rclone:mega:laptop-backup snapshots
#   restic -r rclone:mega:laptop-backup restore latest --target ~/restore
#   (paths in the backup are relative to ~, e.g. one folder: --include /Documents/Resumes)

set -uo pipefail

# Keep the laptop awake while backing up: hypridle would otherwise suspend after
# 30 min idle and cut the upload. (Closing the lid still suspends; restic keeps
# what was already uploaded and continues from there next run.)
if [ -z "${BACKUP_INHIBITED:-}" ]; then
    export BACKUP_INHIBITED=1
    exec systemd-inhibit --what=sleep:idle --who=backup --why="Backup in progress" --mode=block "$0" "$@"
fi
export RESTIC_REPOSITORY="rclone:mega:laptop-backup"
export RESTIC_PASSWORD_FILE="$HOME/.config/restic/password"
HERE="$(dirname "$(readlink -f "$0")")"
# Cloud storage can be slow to answer the first request; restic only waits 1 min
# for its rclone connection by default ("context deadline exceeded").
OPTS=(-o rclone.timeout=5m)

notify() { notify-send -a Backup "$@" 2>/dev/null || true; }

# Offline (or captive portal)? Skip quietly; the timer tries again tomorrow,
# and Persistent=true catches up at the next boot if a day was missed.
if [ "$(nmcli networking connectivity 2>/dev/null)" != "full" ]; then
    echo "No internet connection, skipping backup."
    exit 0
fi

cd "$HOME" || exit 1
# A run killed mid-way (shutdown, lid close...) leaves a lock that blocks every
# later cleanup. "unlock" only removes stale locks (dead process), never a live one.
restic "${OPTS[@]}" unlock -q

for attempt in 1 2 3; do              # retry transient Drive/network errors
    restic "${OPTS[@]}" backup \
        --files-from "$HERE/paths.txt" \
        --exclude-file "$HERE/excludes.txt" \
        --tag auto
    rc=$?
    [ $rc -eq 0 ] || [ $rc -eq 3 ] && break
    echo "Backup attempt $attempt failed (exit $rc), retrying in 60 s..."
    sleep 60
done
# restic exit 3 = some files couldn't be read (e.g. a file changed mid-backup):
# the snapshot is still saved, so warn but don't treat it as a total failure.
if [ $rc -ne 0 ] && [ $rc -ne 3 ]; then
    notify -u critical "Backup failed" "See: journalctl --user -u backup"
    exit 1
fi
[ $rc -eq 3 ] && notify "Backup finished with warnings" "Some files couldn't be read. See: journalctl --user -u backup"

# Keep 7 daily, 4 weekly and 6 monthly versions; delete older ones.
restic "${OPTS[@]}" forget --tag auto --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune \
    || notify "Backup cleanup failed" "The backup itself succeeded."
