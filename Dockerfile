# Version: 0.0.3

# Используем за основу контейнера Ubuntu 14.04 LTS
FROM ubuntu:14.04

# Переключаем Ubuntu в неинтерактивный режим — чтобы избежать лишних запросов
ENV DEBIAN_FRONTEND noninteractive 

# Устанавливаем локаль
RUN locale-gen ru_RU.UTF-8 && dpkg-reconfigure locales

# Устанавливаем время
RUN echo Asia/Yekaterinburg >/etc/timezone && dpkg-reconfigure -f noninteractive tzdata 

# Добавляем необходимые репозитарии и устанавливаем пакеты
RUN apt-get update
RUN apt-get install -y wget curl git unrar-free cron supervisor
RUN apt-get clean

# Установка скрипта nod32mirror
RUN git clone https://github.com/tarampampam/nod32-update-mirror.git
RUN mkdir -p /home/scripts
RUN mkdir -p /home/nod32mirror
RUN mv ./nod32-update-mirror/nod32-mirror /home/scripts
RUN mv ./nod32-update-mirror/webroot /home/nod32mirror
COPY settings.conf /home/scripts/nod32-mirror/conf.d/default.conf
COPY bootstrap.sh /home/scripts/nod32-mirror/include/bootstrap.sh
RUN find /home/scripts -type f -name '*.sh' -exec chmod +x {} \;

# Очистка 
RUN rm -Rf /nod32-update-mirror/

# Настройка cron
RUN echo '0 */3 * * * root /home/scripts/nod32-mirror/nod32-mirror.sh --update >> /home/scripts/nod32-mirror/log.txt' > /etc/crontab
RUN touch /home/scripts/nod32-mirror/log.txt

# Запускаем cron
CMD ["cron", "-f"]
