# >>> claude-doctor: netskope-certs >>>
# Regenerates cert bundle if missing or older than 24 hours
_cert_file="$_NS_COMBINED_CERT"
if [[ ! -f "$_cert_file" ]] || [[ $(find "$_cert_file" -mmin +1440 2>/dev/null) ]]; then
  security find-certificate -a -p \
    /System/Library/Keychains/SystemRootCertificates.keychain \
    /Library/Keychains/System.keychain > "$_cert_file" 2>/dev/null
fi
if [[ -f "$_cert_file" ]]; then
  export NODE_EXTRA_CA_CERTS="$_cert_file"
  export REQUESTS_CA_BUNDLE="$_cert_file"
  export SSL_CERT_FILE="$_cert_file"
  export DENO_TLS_CA_STORE='system'
fi
unset _cert_file
# <<< claude-doctor: netskope-certs <<<
