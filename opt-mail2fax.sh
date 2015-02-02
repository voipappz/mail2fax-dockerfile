#!/bin/bash
email=$(< /dev/stdin)
uuid=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)
dir=/var/faxes
echo "Reading:${email} with args: $1,$2,$3 into: ${dir}/$uuid" >> /var/log/mail.log
echo "${email}" > ${dir}/$uuid
