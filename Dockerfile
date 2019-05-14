FROM debian:stretch

MAINTAINER Julydate <i@xhtml.love>

RUN apt-get update \
	    && apt-get -q -y dist-upgrade \
	    && apt-get -q -y install --no-install-recommends openssh-server pwgen \
		&& apt-get -q -y install wget vim nano cron git python python-pip libssl-dev python-dev libffi-dev python-setuptools gcc libsodium-dev openssl \
		&& pip install cymysql \
	    && apt-get clean \
	    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
		&& wget -O /tmp/shadowsocksr.tar.gz https://github.com/NimaQu/shadowsocks/archive/manyuser.tar.gz \
		&& tar zxf /tmp/shadowsocksr.tar.gz -C /tmp \
		&& mv /tmp/shadowsocks-manyuser /usr/local/shadowsocksr \
		&& cp /usr/local/shadowsocksr/apiconfig.py /usr/local/shadowsocksr/userapiconfig.py \
		&& cp /usr/local/shadowsocksr/config.json /usr/local/shadowsocksr/user-config.json \
		&& rm -fr /tmp/shadowsocks-manyuser \
		&& rm -f /tmp/shadowsocksr.tar.gz
RUN mkdir /var/run/sshd
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
ADD set_root_pw.sh /set_root_pw.sh
ADD superupdate.sh /superupdate.sh
ADD run.sh /run.sh
ADD autostart.sh /autostart.sh
RUN chmod +x /*.sh
# Add ssr keeper
ADD runssr.sh /usr/local/shadowsocksr/runssr.sh
RUN chmod +x /usr/local/shadowsocksr/*.sh
# RUN [[ -e /usr/local/crontab.bak ]] && crontab -l > "/usr/local/crontab.bak" && sed -i "/runssr.sh/d" "/usr/local/crontab.bak"
# RUN echo -e "\n * * * * * /bin/bash /usr/local/shadowsocksr/runssr.sh" >> "/usr/local/crontab.bak"
# RUN crontab "/usr/local/crontab.bak"

EXPOSE 22
CMD ["/run.sh"]
