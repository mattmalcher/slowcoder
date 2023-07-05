Can I get starcoder running on CPU giving me code completions in VSCode?


# Inference Server

HuggingFace make their text generation inference server available at: https://github.com/huggingface/text-generation-inference

The example they give is:

```sh
model=
num_shard=2
volume=$PWD/data # share a volume with the Docker container to avoid downloading weights every run

docker run --gpus all --shm-size 1g -p 8080:80 -v $volume:/data ghcr.io/huggingface/text-generation-inference:0.9 --model-id bigscience/bloom-560m 
```

I have set this up as a compose file in [infra](infra/docker-compose.yml) but excluded the gpu bits and changed the model to starcoder.


# Storing Token

The starcoder model is available, but requires you to pull the model using an access token from an account that has accepted the licence conditions.

Need a way of storing an API token somewhere safe. Using `secret-tool`.

https://manpages.ubuntu.com/manpages/bionic/man1/secret-tool.1.html

```sh

secret-tool store --label='HuggingFace Access Token (read)' api hf_read
secret-tool lookup api hf_read
> hf_yourapikeyblahblah

```

# VSCode Extension

There are two options:
