# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.202.3/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version (use hirsuite or bionic on local arm64/Apple Silicon): hirsute, focal, bionic
ARG VARIANT="hirsute"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

#RUN apt-get update && apt-get install -y --no-install-recommends net-tools iputils-ping openssh-client openssh-server

# Set up a tools dev directory
WORKDIR /home/dev

# Install Cmake packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        net-tools iputils-ping openssh-client openssh-server\
        build-essential \
        cmake gdb make ninja-build\
        gcovr lcov\
        git git-lfs\
        clang-format clang-tidy \
        pkg-config \
        ccache zsh \
        doxygen \
        cppcheck \
        clang lld llvm clang-tools \
    && wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/6-2017q2/gcc-arm-none-eabi-6-2017-q2-update-linux.tar.bz2 \
    && tar xvf gcc-arm-none-eabi-6-2017-q2-update-linux.tar.bz2 \
    && rm gcc-arm-none-eabi-6-2017-q2-update-linux.tar.bz2 \
    && apt-get clean

# Run some configuration commands
RUN mkdir /var/run/sshd
RUN echo 'root:temppwd' | chpasswd
RUN sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

# Set up the compiler path
ENV PATH="/home/dev/gcc-arm-none-eabi-6-2017-q2-update/bin:${PATH}"

WORKDIR /usr/project