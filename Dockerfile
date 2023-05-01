FROM ubuntu:latest
RUN apt update && apt install -y sudo git make vim
RUN useradd -m trimclain && echo "trimclain:pass" | chpasswd && adduser trimclain sudo && chown -R trimclain:trimclain /home/trimclain
USER trimclain
COPY --chown=trimclain:trimclain . /home/trimclain/ytd
WORKDIR /home/trimclain/ytd
CMD ["/bin/bash"]
