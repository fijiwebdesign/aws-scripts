
INTERACTIVE=1
for arg in "$@"; do
  if [ $arg = '--non-interactive' ]; then
    INTERACTIVE=0
  fi
done

if [ $INTERACTIVE -eq 1 ]; then
  echo "*** Are you sure to delete the VPC (y/n)? "
  read answer
  echo "${answer#[Nn]}"
  if [ "$answer" != "${answer#[Nn]}" ] ;then
      exit 1
  fi
fi

