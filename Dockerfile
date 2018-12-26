FROM ubuntu:17.10

ENV DOCKER=1 PHANTOMJS_VERSION="2.1.1"

# install phantomjs
RUN sed -i 's/http:\/\/archive.ubuntu.com\//http:\/\/mirrors.tuna.tsinghua.edu.cn\//g' /etc/apt/sources.list && \
    sed -i '/security/d' /etc/apt/sources.list && \
    apt-get -y update && \
    apt-get -yqq install curl python3 python3-pip mariadb-server libmysqlclient-dev nginx wget bzip2 libfreetype6 libfontconfig && \
    mkdir -p /srv/var && \
    wget --local-encoding=UTF-8 --no-check-certificate -O /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
    tar -xjf /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -C /tmp && \
    rm -f /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
    mv /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/ /srv/var/phantomjs && \
    ln -s /srv/var/phantomjs/bin/phantomjs /usr/bin/phantomjs && \
    pip3 install django gunicorn mysqlclient requests lxml pyyaml django-simple-captcha

COPY files/ /tmp/

# RUN ls -al /tmp && \
#     find /etc/mysql/

# RUN mv /tmp/mysqld.cnf /etc/mysql/mariadb.conf.d/mysqld.cnf && \
RUN mv /tmp/docker-entrypoint /usr/local/bin/docker-entrypoint && \
    mv /tmp/app /app && \
    mv /tmp/scripts /xss && \
    # challenge files and configs
    mv /tmp/nginx/default /etc/nginx/sites-available/default

RUN rm -rf /var/lib/mysql && \
    mysql_install_db --user=mysql --datadir=/var/lib/mysql && \
    sh -c 'mysqld_safe &' && \
    sleep 5s && \
    mysqladmin -uroot password 'FUCKmyL1f3AZiwqeci' && \
    mysql -e "source /tmp/dump.sql;" -uroot -pFUCKmyL1f3AZiwqeci && \
    cd /app && \
    python3 manage.py migrate && \
    python3 manage.py loaddata admin && \
    # xss user && \
    groupadd -g 1000 xss-man && useradd -g xss-man -u 1000 xss-man && \
    chown -R xss-man:xss-man /xss/ && \
    chmod 500 /xss/* && \
    chmod +x /usr/local/bin/docker-entrypoint && \
    rm -rf /tmp/*

# ENTRYPOINT ["supervisord", "-n"]
ENTRYPOINT ["sh", "-c", "docker-entrypoint"]
