FROM transformers:ds
LABEL maintainer="tothemoon"
WORKDIR /workspace

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN type -p curl >/dev/null || (apt update && apt install curl -y) \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh -y
RUN apt update
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

# https://docs.nvidia.com/networking/m/view-rendered-page.action?abstractPageId=15049785
# https://network.nvidia.com/products/infiniband-drivers/linux/mlnx_ofed/
ENV MOFED_VER=23.07-0.5.0.0
ENV PLATFORM=x86_64
RUN OS_VER="ubuntu$(lsb_release -rs)" \
    && wget http://content.mellanox.com/ofed/MLNX_OFED-${MOFED_VER}/MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}.tgz \
    && tar -xvf MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}.tgz \
    && rm -rf MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}.tgz \
    && MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}/mlnxofedinstall --user-space-only --without-fw-update -q \
    && rm -rf MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}

RUN python3 -m pip install -U --no-cache-dir setuptools
RUN python3 -m pip install -U --no-cache-dir pip
RUN python3 -m pip install -U --no-cache-dir gradio
RUN python3 -m pip install -U --no-cache-dir pudb
RUN python3 -m pip install -U --no-cache-dir xformers
RUN python3 -m pip install -U --no-cache-dir bitsandbytes
RUN python3 -m pip install -U --no-build-isolation --no-cache-dir flash-attn
RUN python3 -m pip install -U --no-cache-dir install git+https://github.com/wookayin/gpustat.git@master
RUN python3 -m pip install -U --no-cache-dir ipykernel
RUN python3 -m pip install -U --no-cache-dir ipywidgets
RUN python3 -m pip install -U --no-cache-dir httpx[socks]
RUN python3 -m pip install -U --no-cache-dir wandb

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

# RUN cd /workspace \
#     && git clone https://github.com/vllm-project/vllm.git \
#     && cd vllm \
#     && TORCH_CUDA_ARCH_LIST="7.0;7.5;8.6;8.9;9.0" pip install -e .

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
