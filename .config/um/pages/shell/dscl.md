# dscl --
{:data-section="shell"}
{:data-date="June 02, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Deal with users

## OPTIONS

`dscl . append /Groups/admin GroupMembership usershortname`
: add user

`dscl . delete /Groups/admin GroupMembership usershortname`
: remove user from group

`dscl . read /Groups/admin GroupMembership`
: read membership of admin group

`sudo dseditgroup -o edit -a lucasburns -t user admin`
: add user to group admin

`dscl . -read /Users/$USER UserShell`
: get user shell

`sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh`
: change user shell

`$ dscl . -list /Groups`
: list all groups and system group accounts

`$ dscl . -list /Groups | grep -v '^_'`
: list all group accounts

`$ dscl . -read /Groups/staff RealName`
: read/list "RealName" property for group "staff"

`$ dscl . -read /Groups/staff`
: list all properties for group "staff"

`$ dscacheutil -q group -a name <groupname>`
: same as above but less verbose

### ADDING GROUPS

`$ dscl . -create <record_path> <key> <val>`
: outline

`$ dscl . -create /Groups/employees`
: create group 'employees'

`$ dscl . -create /Groups/<groupname> RealName "<realname>"`
: create group and set full name

`$ dscl . -create /Groups/employees PrimaryGroupID 503`
: create group and set group's group ID (GID)

### MODIFY GROUPS

`$ dscl . -change <record_path> <key> <old_val> <new_val>`
: outline

`$ dscl . -change /Groups/<groupname> PrimaryGroupID <old_id> <new_id>`
: change groups id

`$ dscl . -change /Groups/employees PrimaryGroupID 1000 1001`
: example of changing group ID

### DELETE GROUPS

`$ dscl . -delete <record_path>`
: outline

`$ dscl . -delete /Groups/<groupname>`
: another outline

`$ dseditgroup -o delete <groupname>`
: *dseditgroup* can be used to delete group

### GROUP MEMBERSHIP

`$ dscl . -list /Groups GroupMembership`
: list all group memberships

`$ dscl . -read /Groups/<groupname> GroupMembership`
: list membership of a group

`$ dseditgroup -o checkmember -m <user_to_check> <groupname>`
: check membership of a group

`$ dseditgroup -o edit -a <username_to_add> -t user <groupname>`
: add user to group

`$ dseditgroup -o edit -d <username_to_delete> -t user <groupname>`
: delete user from group
