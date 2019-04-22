#! /bin/bash -u

function usage()
{
  e_header "Usage sms.sh <text>"
  echo
  e_arrow "$@"
}

. $HOME/.bash_logging

if [ -z ${FREE_USER+x} ]; then usage "Please set FREE_USER variable" ; exit 1; fi
if [ -z ${FREE_PASS+x} ]; then usage "Please set FREE_PASS variable"; exit 1; fi

if [ $# -lt 1 ]
then
  usage "Please set FREE_USER and FREE_PASS variables"
  exit 1
fi
msg=`echo "${1}" | sed -e 's/\n/%0A/g'`
echo $msg

RETRY=3
for((i=0;i<RETRY;++i))
do
  send=$(curl -i --insecure "https://smsapi.free-mobile.fr/sendmsg?user=$FREE_USER&pass=$FREE_PASS&msg=${msg}" 2>&1)
  receive=$(echo "$send" | awk '/HTTP/ {print $2}')
  case $receive  in
    200)
      e_success "Message sent correctly"
      break
      ;;
    400)
      e_error "Credentials are incorrect. Please check FREE_PASS and FREE_USER variable" ;;
    402)
      e_error "Too many SMS sent in a short period" ;;
    403)
      e_error "Service not activated" ;;
    500)
      e_error "Error in server side. Please retry later" ;;
    *) e_error "Error code = [$receive]";;
  esac
done
exit 0
