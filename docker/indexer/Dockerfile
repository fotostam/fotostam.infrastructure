FROM ubuntu:18.04

# Add sh file to run
ADD index.sh /root/index.sh
ADD reindex.sh /root/reindex.sh

#Install Cron
RUN apt-get update
RUN apt-get -y install curl imagemagick file inotify-tools

# Run the command on container startup
CMD /root/index.sh
