from ubuntu:12.04
maintainer Vo Minh Thu <noteed@gmail.com>

run apt-get update
run apt-get install -q -y language-pack-en
run update-locale LANG=en_US.UTF-8

run echo mail > /etc/hostname
add etc-hosts.txt /etc/hosts
run chown root:root /etc/hosts

run apt-get install -q -y vim ngrep tcpdump curl sudo

RUN mkdir -p /etc/sudoers.d/
RUN echo 'mail2fax ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/mail2fax
RUN chmod 0440 /etc/sudoers.d/mail2fax

# Install Postfix.
run echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt
run echo "postfix postfix/mailname string mail.voipappz.com" >> preseed.txt
# Use Mailbox format.
run debconf-set-selections preseed.txt
run DEBIAN_FRONTEND=noninteractive apt-get install -q -y postfix


# add 
add etc-virtual-aliases /etc/postfix/virtual_aliases
run chown root:root /etc/postfix/virtual_aliases

# add 
add etc-postfix-transport /etc/postfix/transport
run chown root:root /etc/postfix/transport

# postmap
run /usr/sbin/postmap /etc/postfix/virtual_aliases
run /usr/sbin/postmap /etc/postfix/transport

# add 
add etc-postfix-master.cf /etc/postfix/master.cf
run chown root:root /etc/postfix/master.cf

# add  mailname
add etc-mailname /etc/mailname
run chown root:root /etc/mailname

run postconf -e myhostname=mail.voipappz.com
run postconf -e mydestination="mail.voipappz.com, voipappz.com, localhost.localdomain, localhost"
run postconf -e mail_spool_directory="/var/spool/mail/"
run postconf -e mailbox_command=""
run postconf -e transport_maps="hash:/etc/postfix/transport"
run postconf -e virtual_alias_maps="hash:/etc/postfix/virtual_aliases"
run postconf -e debug_peer_list="voipappz.com"
run postconf -e debug_peer_level="2"
run postconf -e luser_relay="root@voipappz.com"
run postconf -e local_recipient_maps=""


# add 
#add Gemfile /opt/Gemfile
add opt-mail2fax.sh /opt/mail2fax.sh
run chmod +x /opt/mail2fax.sh

# rvm
#RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
#RUN /bin/bash -l -c "curl -L get.rvm.io | bash -s stable"
#RUN /bin/bash -l -c "rvm install 2.1"
#RUN /bin/bash -l -c "gem install bundler"
#RUN echo 'source /etc/profile.d/rvm.sh' >> ~/.bashrc
#RUN /usr/local/rvm/bin/rvm-shell -c "rvm requirements"

#RUN /bin/bash -l -c "bundle install --gemfile /opt/Gemfile"
#RUN /bin/bash -l -c "source /usr/local/rvm/bin/rvm"

RUN mkdir /var/faxes
RUN chmod 777 /var/faxes



# mail.log
RUN echo "first" > /var/log/mail.log
RUN chmod 777 /var/log/mail.log


# Add a local user to receive mail at someone@example.com, with a delivery directory
# (for the Mailbox format).
run useradd -s /bin/bash mail2fax
run mkdir /var/spool/mail/mail2fax
run chown mail2fax:mail /var/spool/mail/mail2fax

add etc-aliases.txt /etc/aliases
run chown root:root /etc/aliases
run newaliases

# Use syslog-ng to get Postfix logs (rsyslog uses upstart which does not seem
# to run within Docker).
run apt-get install -q -y syslog-ng

expose 25
cmd ["sh", "-c", "service syslog-ng start ; service postfix start ; tail -F /var/log/mail.log"]
