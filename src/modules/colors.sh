#!/usr/bin/env bash

RESET='\e[0m'
NC='\e[0m'
ENDCOLOR="\e[0m"

BOLD='\e[1m'
DIM='\e[2m'
ITALIC='\e[3m'
UNDERLINE='\e[4m'
REVERSED='\e[7m'
HIDDEN='\e[8m'

BLACK='\e[0;30m'
RED='\e[0;31m'
GREEN='\e[0;32m'
YELLOW='\e[0;33m'
BLUE='\e[0;34m'
MAGENTA='\e[0;35m'
CYAN='\e[0;36m'
WHITE='\e[0;37m'

BBLACK='\e[1;30m'
BRED='\e[1;31m'
BGREEN='\e[1;32m'
BYELLOW='\e[1;33m'
BBLUE='\e[1;34m'
BMAGENTA='\e[1;35m'
BCYAN='\e[1;36m'
BWHITE='\e[1;37m'

UBLACK='\e[4;30m'
URED='\e[4;31m'
UGREEN='\e[4;32m'
UYELLOW='\e[4;33m'
UBLUE='\e[4;34m'
UMAGENTA='\e[4;35m'
UCYAN='\e[4;36m'
UWHITE='\e[4;37m'

ON_BLACK='\e[40m'
ON_RED='\e[41m'
ON_GREEN='\e[42m'
ON_YELLOW='\e[43m'
ON_BLUE='\e[44m'
ON_MAGENTA='\e[45m'
ON_CYAN='\e[46m'
ON_WHITE='\e[47m'

LBLACK='\e[0;90m'
LRED='\e[0;91m'
LGREEN='\e[0;92m'
LYELLOW='\e[0;93m'
LBLUE='\e[0;94m'
LMAGENTA='\e[0;95m'
LCYAN='\e[0;96m'
LWHITE='\e[0;97m'

BLBLACK='\e[1;90m'
BLRED='\e[1;91m'
BLGREEN='\e[1;92m'
BLYELLOW='\e[1;93m'
BLBLUE='\e[1;94m'
BLMAGENTA='\e[1;95m'
BLCYAN='\e[1;96m'
BLWHITE='\e[1;97m'

ON_LBLACK='\e[100m'
ON_LRED='\e[101m'
ON_LGREEN='\e[102m'
ON_LYELLOW='\e[103m'
ON_LBLUE='\e[104m'
ON_LMAGENTA='\e[105m'
ON_LCYAN='\e[106m'
ON_LWHITE='\e[107m'

INFO="${BLUE}ℹ️  INFO:${NC} "
WARN="${YELLOW}⚠️  WARNING:${NC} "
ERROR="${RED}❌ ERROR:${NC} "
SUCCESS="${GREEN}✅ SUCCESS:${NC} "
NOTE="${MAGENTA}📝 NOTE:${NC} "
