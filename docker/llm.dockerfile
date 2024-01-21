FROM transformers:ds
LABEL maintainer="tothemoon"
WORKDIR /workspace

RUN type -p curl >/dev/null || (apt update && apt install curl -y)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt update \
  && apt install gh -y

RUN apt update
RUN apt install -y netcat
RUN apt install -y git-lfs
RUN apt install -y htop
RUN apt install -y screen
RUN apt install -y tmux
RUN apt install -y locales \
    && locale-gen en_US.UTF-8 \
    && locale-gen zh_CN.UTF-8 \
    && echo -e 'export LANG=zh_CN.UTF-8' >> /root/.bashrc
RUN apt install -y net-tools
RUN apt install -y openssh-server \
    && sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config \
    && sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/" /etc/ssh/sshd_config \
    && sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config \
    && echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
    && mkdir -p /run/sshd
RUN apt install -y pdsh \
    && chown root:root /usr/lib/x86_64-linux-gnu/pdsh \
    && chmod 755 /usr/lib/x86_64-linux-gnu/pdsh \
    && chown root:root /usr/lib \
    && chmod 755 /usr/lib
RUN apt install -y bash-completion
RUN apt install -y socat

# https://network.nvidia.com/products/infiniband-drivers/linux/mlnx_ofed/
ENV MOFED_VER=23.10-1.1.9.0
ENV PLATFORM=x86_64
RUN OS_VER="ubuntu$(cat /etc/os-release | grep VERSION_ID | cut -d '"' -f 2)" \
    && wget http://content.mellanox.com/ofed/MLNX_OFED-${MOFED_VER}/MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}.tgz \
    && tar -xvf MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}.tgz \
    && rm -rf MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}.tgz
RUN OS_VER="ubuntu$(cat /etc/os-release | grep VERSION_ID | cut -d '"' -f 2)" \
    && MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}/mlnxofedinstall --user-space-only --without-fw-update -q \
    && rm -rf MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}

RUN pip install -U --no-cache-dir pip
RUN python3 -m pip install -U --no-cache-dir tiktoken
RUN python3 -m pip install -U --no-cache-dir setuptools
RUN python3 -m pip install -U --no-cache-dir pip
RUN python3 -m pip install -U --no-cache-dir gradio
RUN python3 -m pip install -U --no-cache-dir pudb
RUN python3 -m pip install -U --no-cache-dir xformers --index-url https://download.pytorch.org/whl/cu118
RUN python3 -m pip install -U --no-cache-dir bitsandbytes
RUN python3 -m pip install -U --no-build-isolation --no-cache-dir flash-attn
RUN git clone https://github.com/Dao-AILab/flash-attention.git \
    && cd flash-attention/csrc/layer_norm \
    && python3 -m pip install .
RUN python3 -m pip install -U --no-cache-dir install git+https://github.com/wookayin/gpustat.git@master \
    && pip uninstall -y nvidia-ml-py3 pynvml \
    && pip install --force-reinstall --ignore-installed 'nvidia-ml-py'
RUN python3 -m pip install -U --no-cache-dir ipykernel
RUN python3 -m pip install -U --no-cache-dir ipywidgets
RUN python3 -m pip install -U --no-cache-dir httpx[socks]
RUN python3 -m pip install -U --no-cache-dir wandb
RUN python3 -m pip install -U --no-cache-dir openpyxl
RUN python3 -m pip install -U --no-cache-dir jsonlines 
RUN python3 -m pip install -U --no-cache-dir transformers-stream-generator 
RUN python3 -m pip install -U --no-cache-dir tiktoken
RUN python3 -m pip install -U --no-cache-dir fire 

RUN cd /workspace && \
    git clone https://github.com/huggingface/accelerate.git && \
    python3 -m pip uninstall -y accelerate && \
    cd accelerate && \
    python3 -m pip install -e .

RUN cd /workspace && \
    git clone https://github.com/huggingface/trl.git && \
    python3 -m pip uninstall -y trl && \
    cd trl && \
    python3 -m pip install -e .

RUN cd /workspace/transformers && \
    git pull && \
    python3 -m pip uninstall -y transformers && \
    python3 -m pip install -e .

RUN cd /workspace && \
    git clone https://github.com/huggingface/peft.git && \
    python3 -m pip uninstall -y peft && \
    cd peft && \
    python3 -m pip install -e .

# vim
RUN wget -O /root/.vimrc 'https://api.onedrive.com/v1.0/shares/u!aHR0cHM6Ly8xZHJ2Lm1zL3UvcyFBc01LbTN0MEszbFlnWlZsc0JJM1hhTGR3bWNJNHc/root/content' \
    && git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim \
    && vim +PluginInstall +qall

# pudb
RUN mkdir -p /root/.config/pudb \
    && wget -O /root/.config/pudb/pudb.cfg 'https://api.onedrive.com/v1.0/shares/u!aHR0cHM6Ly8xZHJ2Lm1zL3UvcyFBc01LbTN0MEszbFlnWlZrQjlYNDQtTEJHWnoxVVE/root/content'

# htop
RUN mkdir -p /root/.config/htop \
    && wget -O /root/.config/htop/htoprc 'https://api.onedrive.com/v1.0/shares/u!aHR0cHM6Ly8xZHJ2Lm1zL3UvcyFBc01LbTN0MEszbFlnWllUeHZqZUMyb2N0MzVKZlE/root/content'

# screenrc
RUN echo 'termcapinfo xterm* ti@:te@' > /root/.screenrc

RUN mkdir -p /scripts && echo -e '#!/bin/bash\n\
SSHD_PORT=22001\n\
CMD_TO_RUN=""\n\
while (( "$#" )); do\n\
  case "$1" in\n\
    --sshd_port)\n\
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then\n\
        SSHD_PORT=$2\n\
        shift 2\n\
      else\n\
        echo "Error: Argument for $1 is missing" >&2\n\
        exit 1\n\
      fi\n\
      ;;\n\
    --cmd)\n\
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then\n\
        CMD_TO_RUN=$2\n\
        shift 2\n\
      else\n\
        echo "Error: Argument for $1 is missing" >&2\n\
        exit 1\n\
      fi\n\
      ;;\n\
    -*|--*=) \n\
      echo "Error: Unsupported flag $1" >&2\n\
      exit 1\n\
      ;;\n\
    *) \n\
      shift\n\
      ;;\n\
  esac\n\
done\n\
sed -i "s/#Port 22/Port $SSHD_PORT/" /etc/ssh/sshd_config\n\
/usr/sbin/sshd\n\
if [ -n "$CMD_TO_RUN" ]; then\n\
  bash -c "$CMD_TO_RUN"\n\
else\n\
  /bin/bash\n\
fi' > /scripts/startup.sh && chmod +x /scripts/startup.sh

ENTRYPOINT ["/bin/bash", "/scripts/startup.sh"]
