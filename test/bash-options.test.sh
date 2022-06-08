#!/bin/bash

# Update USAGE (USAGE1, USAGE2, USAGE3 may remain unchanged):
USAGE='Usage: prog [-q|--quiet] [-l|--list] [-f file|--file file] [-Q arg|--query arg] args'
USAGE1='
Ambiguously abbreviated long option:'
USAGE2='
No such option:'
USAGE3='
Missing argument for'

# List all long options here (including leading --):
LONGOPTS=(--quiet --list --file --query)

# List all short options that take an option argument here
# (without separator, without leading -):
SHORTARGOPTS=fQ

while [[ $# -ne 0 ]] ; do
  # This part remains unchanged
  case $1 in
  --) shift ; break ;;  ### no more options
  -)  break ;;          ### no more options
  -*) ARG=$1 ; shift ;;
  *)  break ;;          ### no more options
  esac

  # This part remains unchanged
  case $ARG in
  --*)
    FOUND=0
    for I in "${LONGOPTS[@]}" ; do
      case $I in
      "$ARG")  FOUND=1 ; OPT=$I ; break ;;
      "$ARG"*) (( FOUND++ )) ; OPT=$I ;;
      esac
    done
    case $FOUND in
    0) echo "$USAGE$USAGE2 $ARG" 1>&2 ; exit 1 ;;
    1) ;;
    *) echo "$USAGE$USAGE1 $ARG" 1>&2 ; exit 1 ;;
    esac ;;
  -["$SHORTARGOPTS"]?*)
    OPT=${ARG:0:2}
    set dummy "${ARG:2}" "$@"
    shift ;;
  -?-*)
    echo "$USAGE" 1>&2 ; exit 1 ;;
  -??*)
    OPT=${ARG:0:2}
    set dummy -"${ARG:2}" "$@"
    shift ;;
  -?)
    OPT=$ARG ;;
  *)
    echo "OOPS, this can't happen" 1>&2 ; exit 1 ;;
  esac

  # Give both short and long form here.
  # Note: If the option takes an option argument, it it found in $1.
  # Copy the argument somewhere and shift afterwards!
  case $OPT in
  -q|--quiet) QUIETMODE=yes ;;
  -l|--list)  LISTMODE=yes ;;
  -f|--file)  [[ $# -eq 0 ]] && { echo "$USAGE$USAGE3 $OPT" 1>&2 ; exit 1 ; }
              FILE=$1 ; shift ;;
  -Q|--query) [[ $# -eq 0 ]] && { echo "$USAGE$USAGE3 $OPT" 1>&2 ; exit 1 ; }
              QUERYARG=$1 ; shift ;;
  *)          echo "$USAGE$USAGE2 $OPT" 1>&2 ; exit 1 ;;
  esac
done

# Remaining arguments are now in "$@":

echo "QUIETMODE = $QUIETMODE"
echo "LISTMODE = $LISTMODE"
echo "FILE = $FILE"
echo "QUERYARG = $QUERYARG"
echo "REMAINING ARGUMENTS:" "$@"