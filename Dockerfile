# Version: 0.0.2

# Используем за основу контейнера Ubuntu 14.04 LTS
FROM ubuntu:14.04

# Переключаем Ubuntu в неинтерактивный режим — чтобы избежать лишних запросов
ENV DEBIAN_FRONTEND noninteractive 

# Устанавливаем локаль
RUN locale-gen ru_RU.UTF-8 && dpkg-reconfigure locales

# Устанавливаем времят
RUN echo Asia/Yekaterinburg >/etc/timezone && dpkg-reconfigure -f noninteractive tzdata 

# Добавляем необходимые репозитарии и устанавливаем пакеты
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y nano mc wget curl git unrar-free cron supervisor nginx
RUN apt-get clean

# Установка скрипта nod32mirror
RUN git clone https://github.com/tarampampam/nod32-update-mirror.git
RUN mv ./nod32-update-mirror/webroot /usr/share/nginx/nod32mirror
RUN mkdir -p /home/scripts
RUN mv ./nod32-update-mirror/nod32-mirror /home/scripts
COPY bootstrap.sh /home/scripts/nod32-mirror/include/bootstrap.sh
RUN find /home/scripts -type f -name '*.sh' -exec chmod +x {} \;
COPY default.conf /home/scripts/nod32-mirror/conf.d/default.conf

# Настройка nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY nod32mirror /etc/nginx/sites-available/default

# Установка и настройка cron
COPY crontab /etc/cron.d/hello-cron
RUN chmod +x /etc/cron.d/hello-cron

# Очистка 
RUN rm -Rf /nod32-update-mirror/

# Добавляем конфиг supervisor (описание процессов, которые мы хотим видеть запущенными на этом контейнере)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Объявляем, какой порт этот контейнер будет транслировать
EXPOSE 80

# Запускаем supervisor
CMD ["/usr/bin/supervisord"]
