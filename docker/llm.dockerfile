FROM nvcr.io/nvidia/pytorch:23.04-py3
# ubuntu 20.04
# python 3.8
# cuda 12.1.0
# torch 2.1.0a0+fe05266f
# nccl 2.17.1
LABEL maintainer="tothemoon"
WORKDIR /workspace

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt update -y \
  && apt install gh -y
  
RUN apt install -y libaio-dev
RUN apt install -y netcat
RUN apt install -y git-lfs
RUN apt install -y htop
RUN apt install -y screen
RUN apt install -y tmux
RUN apt install -y locales \
    && locale-gen en_US.UTF-8 \
    && locale-gen zh_CN.UTF-8 \
    && echo -e 'export LANG=zh_CN.UTF-8' >> /root/.bashrc
RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
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
RUN apt install -y locate
RUN apt install -y cron
RUN apt install -y zip
RUN apt install -y fuse

# IB网卡驱动：https://network.nvidia.com/products/infiniband-drivers/linux/mlnx_ofed/
# ENV MOFED_VER=23.10-1.1.9.0
# ENV PLATFORM=x86_64
# RUN OS_VER="ubuntu$(cat /etc/os-release | grep VERSION_ID | cut -d '"' -f 2)" \
#     && wget http://content.mellanox.com/ofed/MLNX_OFED-${MOFED_VER}/MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}.tgz \
#     && tar -xvf MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}.tgz \
#     && rm -rf MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}.tgz
# RUN OS_VER="ubuntu$(cat /etc/os-release | grep VERSION_ID | cut -d '"' -f 2)" \
#     && MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}/mlnxofedinstall --user-space-only --without-fw-update -q \
#     && rm -rf MLNX_OFED_LINUX-${MOFED_VER}-${OS_VER}-${PLATFORM}

RUN pip install -U --no-cache-dir pip
RUN pip install -U --no-cache-dir setuptools
# 可能影响pytorch版本，进而影响nccl版本
RUN pip install -U --no-cache-dir --no-deps xformers==0.0.22.post7 --index-url https://download.pytorch.org/whl/cu121
# RUN pip download xformers==0.0.22.post7 --no-deps --index-url https://download.pytorch.org/whl/cu121 \
#     && XFORMERS_WHL=$(ls xformers-*.whl) \
#     && unzip $XFORMERS_WHL -d xformers_package \
#     && rm $XFORMERS_WHL \
#     && sed -i 's/torch ==2.1.0/torch ==2.1.0a0+fe05266f/g' xformers_package/xformers-0.0.22.post7.dist-info/METADATA \
#     && cd xformers_package \
#     && zip -r ../$XFORMERS_WHL * \
#     && cd .. \
#     && rm -r xformers_package \
#     && pip install $XFORMERS_WHL --no-cache-dir \
#     && rm $XFORMERS_WHL
# 依赖pytorch，需要重新编译
RUN git clone https://github.com/Dao-AILab/flash-attention.git \
    && cd flash-attention \
    && MAX_JOBS=1 python setup.py install    
RUN cd flash-attention \
    && cd flash-attention/csrc/layer_norm \
    && MAX_JOBS=1 pip install .
RUN pip install -U --no-cache-dir bitsandbytes

RUN pip install -U --no-cache-dir gradio
RUN pip install -U --no-cache-dir pudb
RUN pip install -U --no-cache-dir install git+https://github.com/wookayin/gpustat.git@master \
    && pip uninstall -y nvidia-ml-py3 pynvml \
    && pip install --force-reinstall --ignore-installed 'nvidia-ml-py'
RUN pip install -U --no-cache-dir ipykernel
RUN pip install -U --no-cache-dir ipywidgets
RUN pip install -U --no-cache-dir httpx[socks]
RUN pip install -U --no-cache-dir wandb
RUN pip install -U --no-cache-dir openpyxl
RUN pip install -U --no-cache-dir jsonlines
RUN pip install -U --no-cache-dir fire
RUN pip install -U --no-cache-dir rich
# huggingface全家桶
RUN pip uninstall -y trl accelerate transformer peft deepspeed datasets \
    && pip install --no-cache-dir trl[deepspeed,peft] datasets

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

CMD ["/bin/bash", "/scripts/startup.sh"]
