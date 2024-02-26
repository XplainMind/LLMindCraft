export https_proxy=http://127.0.0.1:65531
export http_proxy=http://127.0.0.1:65531
export all_proxy=socks5://127.0.0.1:65531

docker build --network host --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg all_proxy=$all_proxy -t vllm -f vllm.dockerfile .