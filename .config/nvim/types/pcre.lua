---@module 'rex_pcre2'
---@meta

---@class PCRE
local rex = {}

---@alias PCRERegex string|PCREObj
---@alias PCRERet0 (string|number)?
---@alias PCRERet1 (string|false)?
---@alias PCRECapture string
---@alias PCRECaptures (PCRECapture|false)[]
---@alias PCREExecutionFlags integer
---@alias PCREControlFn fun(start: number, end: number, out: string): PCRERet0|boolean, number|boolean|nil

---@alias PCRECompilationFlags PCRECompilationFlagInts|PCRECompilationFlagStrs
---@alias PCRECompilationFlagInts integer
---@alias PCRECompilationFlagStrs
---| "'i'" PCRE2_CASELESS case insensitive matching
---| "'m'" PCRE2_MULTILINE '^' and '$' match after and before newline chars
---| "'s'" PCRE2_DOTALL '.' includes the newline char
---| "'x'" PCRE2_EXTENDED allows inclusion of comments
---| "'U'" PCRE2_UNGREEDY modifiers won't be greedy unless followed by a '?'. can use ('?U')

---Compiles regex `patt` into a regex object (`PCREObj`)
---See: https://rrthomas.github.io/lrexlib/manual.html#new
---@param patt PCRERegex regular expression pattern
---@param cf? PCRECompilationFlags compilation flags (bitwise OR)
---@param ... any library specific arguments or locale from `rex.maketables()`
---@return PCREObj
function rex.new(patt, cf, ...)
end

---Searches for the first match of the regexp `patt` in the string `subj`,
---starting from offset `init`, subject to flags `cf` and `ef`.
---
---See: https://rrthomas.github.io/lrexlib/manual.html#match
---@param subj string subject
---@param patt PCRERegex regular expression pattern
---@param init? integer start offset in the subject (can be negative)
---@param cf? PCRECompilationFlags compilation flags (bitwise OR)
---@param ef? PCREExecutionFlags execution flags (bitwise OR)
---@param ... any library specific arguments
---@return PCRECaptures? captures captures on success
function rex.match(subj, patt, init, cf, ef, ...)
end

---Searches for the first match of the regexp `patt` in the string `subj`,
---starting from offset `init`, subject to flags `cf` and `ef`.
---
---See: https://rrthomas.github.io/lrexlib/manual.html#find
---@param subj string subject
---@param patt PCRERegex regular expression pattern
---@param init? integer start offset in the subject (can be negative)
---@param cf? PCRECompilationFlags compilation flags (bitwise OR)
---@param ef? PCREExecutionFlags execution flags (bitwise OR)
---@param ... any library specific arguments
---@return number? start nil on failure
---@return number? end
---@return PCRECaptures? captures
function rex.find(subj, patt, init, cf, ef, ...)
end

---Intended for use in the generic for-loop construct.
---Returns an iterator for repeated matching of the pattern `patt` in the string `subj`,
---subject to flags `cf` and `ef`.
---
---See: https://rrthomas.github.io/lrexlib/manual.html#gmatch
---@param subj string subject
---@param patt PCRERegex regular expression pattern
---@param cf? PCRECompilationFlags compilation flags (bitwise OR)
---@param ef? PCREExecutionFlags execution flags (bitwise OR)
---@param ... any library specific arguments
---@return (fun(): PCRECaptures)? iterator
function rex.gmatch(subj, patt, cf, ef, ...)
end


---Searches for all matches of the pattern `patt` in the string `subj`,
---and replaces them according to the parameters `repl` and `n`.
---
---## Overview
---More on `repl`. Can be: `string`, `fun()`, or `table`:
---  - `string`: template for substitution
---     - `%0`: entire match
---     - `%1`: first capture, or if no captures, entire match
---     - `%X`: if greater than N matches, produces error
---     - `%a`: substituted with `a`
---  - `function`: called each match, submatches passed as args
---     - `string|number`: returns this and used as replacement
---     - `false|nil`: no replacement is made
---  - `table`: submatches
---
---See: https://rrthomas.github.io/lrexlib/manual.html#gsub
---## Example
---```lua
---  p(rex.gsub('what up', [[\w+]], '--%0--'))         -- => --what-- --up--
---  p(rex.gsub('what up', [[(\w)(\w+)]], '--%1--%2')) -- => --w--hat --u--p
---```
---@param subj string subject
---@param patt PCRERegex regular expression pattern
---@param repl string|table|fun(submatches: ...): PCRERet0|false substitution source
---@param n? integer|PCREControlFn maximum number of matches to search for or control func
---@param cf? PCRECompilationFlags compilation flags (bitwise OR)
---@param ef? PCREExecutionFlags execution flags (bitwise OR)
---@param ... any library specific arguments
---@return string substitued
---@return number matches
---@return number substitutions_made
function rex.gsub(subj, patt, repl, n, cf, ef, ...)
end

---Intended for use in the generic for-loop construct.
---Used for splitting a subject string subj into parts (sections).
---The `sep` parameter is a regex pattern representing separators between the sections.
--
---Returns an iterator for repeated matching of the pattern `sep` in the string `subj`,
---subject to flags `cf` and `ef`.
---
---See: https://rrthomas.github.io/lrexlib/manual.html#split
---@param subj string subject
---@param sep PCRERegex separator (regular expression pattern)
---@param cf? PCRECompilationFlags compilation flags (bitwise OR)
---@param ef? PCREExecutionFlags execution flags (bitwise OR)
---@param ... any library specific arguments
---@return fun(): string, PCRECaptures
function rex.split(subj, sep, cf, ef, ...)
end

---Counts matches of the pattern `patt` in the string `subj`.
---
---See: https://rrthomas.github.io/lrexlib/manual.html#count
---@param subj string subject
---@param patt PCRERegex regular expression pattern
---@param cf? PCRECompilationFlags compilation flags (bitwise OR)
---@param ef? PCREExecutionFlags execution flags (bitwise OR)
---@param ... any library specific arguments
---@return integer matches_found
function rex.count(subj, patt, cf, ef, ...)
end

---Returns a table containing the numeric values of the constants defined by the used
---regex lib, with the keys being the (`string`) names of the constants.
---
---If the table argument `tb` is supplied then it is used as the output table,
---otherwise a new table is created.
---
---See: https://rrthomas.github.io/lrexlib/manual.html#flags
---@param tb? PCRELibFlags[]
---@return PCRELibFlags[]
function rex.flags(tb)
end

---Returns a table containing the values of the configuration
---parameters used at PCRE library build-time. Those parameters (numbers) are
---keyed by their names (strings). If the table argument *tb* is supplied then it
---is used as the output table, else a new table is created.
---@param tb? (PCRELibFlags)[]
---@return (PCRELibFlags)[]
function rex.config(tb)
end

---Creates a set of character tables corresponding to the current locale and
---returns it as a userdata. The returned value can be passed to any Lrexlib
---function accepting the `locale` parameter.
---@return userdata
function rex.maketables()
end

---Returns a string containing the version of the used PCRE library and its release date
---@return string version
function rex.version()
end

--  ══════════════════════════════════════════════════════════════════════

---@class PCREObj
local PCREObj = {}

---Searches for the first match of the already compiled regexp
---in the string `subj`, starting from offset `init`, subject to flags `ef`.
---
---See: https://rrthomas.github.io/lrexlib/manual.html#match
---@param subj string subject
---@param init? integer start offset in the subject (can be negative)
---@param ef? PCREExecutionFlags execution flags (bitwise OR)
---@return PCRECaptures? captures captures on success
function PCREObj:match(subj, init, ef)
end

---Searches for the first match of the already compiled regexp
---in the string `subj`, starting from offset `init`, subject to flags `ef`.
---
---See: https://rrthomas.github.io/lrexlib/manual.html#find
---@param subj string subject
---@param init? integer start offset in the subject (can be negative)
---@param ef? PCREExecutionFlags execution flags (bitwise OR)
---@return number? start nil on failure
---@return number? end
---@return PCRECaptures? captures
function PCREObj:find(subj, init, ef)
end

---Searches for first match in the string `subj`.
---See: https://rrthomas.github.io/lrexlib/manual.html#tfind
---@param subj string subject
---@param init? integer start offset in the subject (can be negative)
---@param ef? PCRECompilationFlags compilation flags (bitwise OR)
---@return integer? start
---@return integer? end
---@return PCRECaptures? captures
function PCREObj:tfind(subj, init, ef)
end

---Searches for first match in the string `subj`.
---See: https://rrthomas.github.io/lrexlib/manual.html#exec
---@param subj string subject
---@param init? integer start offset in the subject (can be negative)
---@param ef? PCRECompilationFlags compilation flags (bitwise OR)
---@return integer? start
---@return integer? end
---@return PCRECaptures? captures
function PCREObj:exec(subj, init, ef)
end

---Returns a table containing information about the compiled pattern.
---The keys are strings formed in the following way:
---  `PCRE_INFO_CAPTURECOUNT` -> `"CAPTURECOUNT"`
---@return PCREInfo
function PCREObj:fullinfo()
end

---Returns a table containing information about the compiled pattern.
---The keys are strings formed in the following way:
---  `PCRE2_INFO_CAPTURECOUNT` -> `"CAPTURECOUNT"`
---@return PCREInfo
function PCREObj:patterninfo()
end

---The method returns ``true`` on success or ``false`` + error message string on failure.
---@param opts integer bitwise OR options. (def: `PCRE2_JIT_COMPLETE`)
---@return boolean|boolean, string
function PCREObj:jit_compile(opts)
end

---Matches a compiled regular expression against a given subject
---string, using a DFA matching algorithm.
---@param subj string subject
---@param init? integer start offset in the subject (can be negative)
---@param ef? PCRECompilationFlags compilation flags (bitwise OR)
---@param ovecsize? integer size of array for result offsets (def: 100)
---@param wscount? integer number of elements in working space array (def: 50)
---@return integer? start
---@return table? endpoints
---@return integer? pcre_dfa_exec return value
function PCREObj:dfa_exec(subj, init, ef, ovecsize, wscount)
end

---@class PCREInfo
---@field ALLOPTIONS number
---@field ARGOPTIONS number
---@field BACKREFMAX number
---@field BSR number
---@field CAPTURECOUNT number
---@field FIRSTCODETYPE number
---@field FIRSTCODEUNIT number,
---@field HASBACKSLASHC number
---@field HASCRORLF number
---@field JCHANGED number
---@field JITSIZE number
---@field LASTCODETYPE number
---@field LASTCODEUNIT number,
---@field MATCHEMPTY number
---@field MAXLOOKBEHIND number
---@field MINLENGTH number
---@field NAMECOUNT number
---@field NAMEENTRYSIZE number
---@field NEWLINE number
---@field SIZE number

---@alias PCRELibFlags
---| "CASELESS"          (`i`) case insensitive matching
---| "MULTILINE"         (`m`) '^' and '$' match after and before newline chars
---| "DOTALL"            (`s`) '.' includes the newline char
---| "EXTENDED"          (`x`) allows inclusion of comments
---| "UNGREEDY"          (`U`) modifiers won't be greedy unless followed by a '?'. can use ('?U')
---| "ANCHORED"          (`A`) pattern is forced to match at start of string
---| "DOLLAR_ENDONLY"    (`D`) '$' matches only end of str. w/o, '$' also match before final char if it's '\n'
---| "UTF"               (`u`) patterns are treated as UTF-8
---| "ALLOW_EMPTY_CLASS"
---| "ALT_BSUX"
---| "ALT_CIRCUMFLEX"
---| "ALT_VERBNAMES"
---| "AUTO_CALLOUT"
---| "BSR_ANYCRLF"
---| "BSR_UNICODE"
---| "DFA_RESTART"
---| "DFA_SHORTEST"
---| "DUPNAMES"
---| "ERROR_BADDATA"
---| "ERROR_BADMAGIC"
---| "ERROR_BADMODE"
---| "ERROR_BADOFFSET"
---| "ERROR_BADOFFSETLIMIT"
---| "ERROR_BADOPTION"
---| "ERROR_BADREPESCAPE"
---| "ERROR_BADREPLACEMENT"
---| "ERROR_BADSERIALIZEDDATA"
---| "ERROR_BADSUBSPATTERN"
---| "ERROR_BADSUBSTITUTION"
---| "ERROR_BADUTFOFFSET"
---| "ERROR_CALLOUT"
---| "ERROR_DFA_BADRESTART"
---| "ERROR_DFA_RECURSE"
---| "ERROR_DFA_UCOND"
---| "ERROR_DFA_UFUNC"
---| "ERROR_DFA_UITEM"
---| "ERROR_DFA_WSSIZE"
---| "ERROR_INTERNAL"
---| "ERROR_JIT_BADOPTION"
---| "ERROR_JIT_STACKLIMIT"
---| "ERROR_MATCHLIMIT"
---| "ERROR_MIXEDTABLES"
---| "ERROR_NOMATCH"
---| "ERROR_NOMEMORY"
---| "ERROR_NOSUBSTRING"
---| "ERROR_NOUNIQUESUBSTRING"
---| "ERROR_NULL"
---| "ERROR_PARTIAL"
---| "ERROR_RECURSELOOP"
---| "ERROR_RECURSIONLIMIT"
---| "ERROR_REPMISSINGBRACE"
---| "ERROR_TOOMANYREPLACE"
---| "ERROR_UNAVAILABLE"
---| "ERROR_UNSET"
---| "ERROR_UTF16_ERR1"
---| "ERROR_UTF16_ERR2"
---| "ERROR_UTF16_ERR3"
---| "ERROR_UTF32_ERR1"
---| "ERROR_UTF32_ERR2"
---| "ERROR_UTF8_ERR1"
---| "ERROR_UTF8_ERR10"
---| "ERROR_UTF8_ERR11"
---| "ERROR_UTF8_ERR12"
---| "ERROR_UTF8_ERR13"
---| "ERROR_UTF8_ERR14"
---| "ERROR_UTF8_ERR15"
---| "ERROR_UTF8_ERR16"
---| "ERROR_UTF8_ERR17"
---| "ERROR_UTF8_ERR18"
---| "ERROR_UTF8_ERR19"
---| "ERROR_UTF8_ERR2"
---| "ERROR_UTF8_ERR20"
---| "ERROR_UTF8_ERR21"
---| "ERROR_UTF8_ERR3"
---| "ERROR_UTF8_ERR4"
---| "ERROR_UTF8_ERR5"
---| "ERROR_UTF8_ERR6"
---| "ERROR_UTF8_ERR7"
---| "ERROR_UTF8_ERR8"
---| "ERROR_UTF8_ERR9"
---| "FIRSTLINE"
---| "INFO_ALLOPTIONS"
---| "INFO_ARGOPTIONS"
---| "INFO_BACKREFMAX"
---| "INFO_BSR"
---| "INFO_CAPTURECOUNT"
---| "INFO_FIRSTBITMAP"
---| "INFO_FIRSTCODETYPE"
---| "INFO_FIRSTCODEUNIT"
---| "INFO_HASBACKSLASHC"
---| "INFO_HASCRORLF"
---| "INFO_JCHANGED"
---| "INFO_JITSIZE"
---| "INFO_LASTCODETYPE"
---| "INFO_LASTCODEUNIT"
---| "INFO_MATCHEMPTY"
---| "INFO_MATCHLIMIT"
---| "INFO_MAXLOOKBEHIND"
---| "INFO_MINLENGTH"
---| "INFO_NAMECOUNT"
---| "INFO_NAMEENTRYSIZE"
---| "INFO_NAMETABLE"
---| "INFO_NEWLINE"
---| "INFO_RECURSIONLIMIT"
---| "INFO_SIZE"
---| "JIT_COMPLETE"
---| "JIT_PARTIAL_HARD"
---| "JIT_PARTIAL_SOFT"
---| "MAJOR"
---| "MATCH_UNSET_BACKREF"
---| "MINOR"
---| "NEVER_BACKSLASH_C"
---| "NEVER_UCP"
---| "NEVER_UTF"
---| "NEWLINE_ANY"
---| "NEWLINE_ANYCRLF"
---| "NEWLINE_CR"
---| "NEWLINE_CRLF"
---| "NEWLINE_LF"
---| "NOTBOL"
---| "NOTEMPTY"
---| "NOTEMPTY_ATSTART"
---| "NOTEOL"
---| "NO_AUTO_CAPTURE"
---| "NO_AUTO_POSSESS"
---| "NO_DOTSTAR_ANCHOR"
---| "NO_JIT"
---| "NO_START_OPTIMIZE"
---| "NO_UTF_CHECK"
---| "PARTIAL_HARD"
---| "PARTIAL_SOFT"
---| "SUBSTITUTE_EXTENDED"
---| "SUBSTITUTE_GLOBAL"
---| "SUBSTITUTE_OVERFLOW_LENGTH"
---| "SUBSTITUTE_UNKNOWN_UNSET"
---| "SUBSTITUTE_UNSET_EMPTY"
---| "UCP"
---| "USE_OFFSET_LIMIT"
