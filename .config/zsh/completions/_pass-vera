#compdef pass-vera
#autoload
#description Manage your password store in a VeraCrypt drive

_pass-vera() {
	_arguments : \
		{-h,--help}'[display help information]' \
		{-V,--version}'[display version information]' \
		{-p,--path}'[gpg-id will only be applied to this subfolder]:dirs:_pass_complete_entries_with_dirs' \
		{-n,--no-init}'[do not initialise the password store]' \
		{-t,--timer}'[close the store after a given time]' \
		{-c,--truecrypt}'[enable TrueCrypt compatibility mode]' \
		{-k,--vera-key}'[use /dev/urandom to create key]' \
    {-i,--invisi-key}'[create a key that deletes itself, but is reusable]' \
		'--tmp-key[create a one-time key]' \
    '--for-me[copy the existing password-store to the location of the new one]' \
    {-r,--reencrypt}'[re-encrypt the files as their being copied to new location (use with --for-me)]' \
		{-o,--overwrite-key}'[overwrite existing key]' \
		{-s,--status}'[get status of the vera (i.e., mounted or not)]' \
		{-f,--force}'[force operation (i.e. even if operations are happening)]' \
		{-q,--quiet}'[be quiet]' \
		{-v,--verbose}'[be verbose]' \
		{-d,--debug}'[print VeraCrypt debug messages]' \
		'--unsafe[speed up vera creation (for testing only)]'

	_pass_complete_keys
}

_pass_complete_entries_with_dirs () {
	_pass_complete_entries_helper -type d
}

_pass-vera "$@"
