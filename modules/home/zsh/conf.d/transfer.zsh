TRANSFERSH_HOST="https://transfer.feliciterra.com"

transfer() {
  if [ -z "$TRANSFER_USER" ] || [ -z "$TRANSFER_PASS" ]; then
    echo "TRANSFER_USER and TRANSFER_PASS must be set in the environment." >&2
    return 1
  fi

  if [ $# -eq 0 ]; then
    echo "No arguments specified.

Usage:
  transfer <file|directory>
  ... | transfer <file_name>

Examples:
  transfer /tmp/test.md" >&2
    return 1
  fi

  file_name=$(basename "$1")

  if [ -t 0 ]; then
    file="$1"
    if [ ! -e "$file" ]; then
      echo "$file: No such file or directory" >&2
      return 1
    fi

    if [ -d "$file" ]; then
      cd "$file" || return 1
      file_name="$file_name.zip"
      set -- zip -r -q - .
    else
      set -- cat "$file"
    fi
  else
    set -- cat
  fi

  url=$("$@" | curl --silent --show-error --progress-bar -u "$TRANSFER_USER:$TRANSFER_PASS" --upload-file "-" "$TRANSFERSH_HOST/$file_name")
  echo "$url"
}
