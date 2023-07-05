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

You can see the options flags of the inference server [here](https://github.com/huggingface/text-generation-inference/blob/main/launcher/src/main.rs)


# Storing Token

The starcoder model is available, but requires you to pull the model using an access token from an account that has accepted the licence conditions.

Need a way of storing an API token somewhere safe. Using `secret-tool`.

https://manpages.ubuntu.com/manpages/bionic/man1/secret-tool.1.html

```sh

secret-tool store --label='HuggingFace Access Token (read)' api hf_read
secret-tool lookup api hf_read
> hf_yourapikeyblahblah

```


# No GPU Errors :(

```
make run_starcoder 
docker-compose \
-f ./infra/docker-compose.yml \
run \
-e HF_API_TOKEN=$(secret-tool lookup api hf_read) \
slowcoder
WARNING: Found orphan containers (infra_huggingface_1) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.
Creating infra_slowcoder_run ... done
2023-07-05T19:53:44.757129Z  INFO text_generation_launcher: Args { model_id: "bigcode/starcoder", revision: None, sharded: None, num_shard: None, quantize: None, dtype: None, trust_remote_code: false, max_concurrent_requests: 128, max_best_of: 2, max_stop_sequences: 4, max_input_length: 1024, max_total_tokens: 2048, waiting_served_ratio: 1.2, max_batch_prefill_tokens: 4096, max_batch_total_tokens: 16000, max_waiting_tokens: 20, port: 80, shard_uds_path: "/tmp/text-generation-server", master_addr: "localhost", master_port: 29500, huggingface_hub_cache: Some("/data"), weights_cache_override: None, disable_custom_kernels: false, json_output: false, otlp_endpoint: None, cors_allow_origin: [], watermark_gamma: None, watermark_delta: None, ngrok: false, ngrok_authtoken: None, ngrok_domain: None, ngrok_username: None, ngrok_password: None, env: false }
2023-07-05T19:53:44.757235Z  INFO text_generation_launcher: Starting download process.
2023-07-05T19:53:46.526492Z  INFO download: text_generation_launcher: Files are already present on the host. Skipping download.

2023-07-05T19:53:46.962418Z  INFO text_generation_launcher: Successfully downloaded weights.
2023-07-05T19:53:46.962826Z  INFO text_generation_launcher: Starting shard 0
2023-07-05T19:53:48.445271Z  WARN shard-manager: text_generation_launcher: We're not using custom kernels.
 rank=0
2023-07-05T19:53:48.448329Z  WARN shard-manager: text_generation_launcher: Could not import Flash Attention enabled models
Traceback (most recent call last):
  File "/opt/conda/bin/text-generation-server", line 8, in <module>
    sys.exit(app())
  File "/opt/conda/lib/python3.9/site-packages/typer/main.py", line 311, in __call__
    return get_command(self)(*args, **kwargs)
  File "/opt/conda/lib/python3.9/site-packages/click/core.py", line 1130, in __call__
    return self.main(*args, **kwargs)
  File "/opt/conda/lib/python3.9/site-packages/typer/core.py", line 778, in main
    return _main(
  File "/opt/conda/lib/python3.9/site-packages/typer/core.py", line 216, in _main
    rv = self.invoke(ctx)
  File "/opt/conda/lib/python3.9/site-packages/click/core.py", line 1657, in invoke
    return _process_result(sub_ctx.command.invoke(sub_ctx))
  File "/opt/conda/lib/python3.9/site-packages/click/core.py", line 1404, in invoke
    return ctx.invoke(self.callback, **ctx.params)
  File "/opt/conda/lib/python3.9/site-packages/click/core.py", line 760, in invoke
    return __callback(*args, **kwargs)
  File "/opt/conda/lib/python3.9/site-packages/typer/main.py", line 683, in wrapper
    return callback(**use_params)  # type: ignore
  File "/opt/conda/lib/python3.9/site-packages/text_generation_server/cli.py", line 64, in serve
    from text_generation_server import server
  File "<frozen importlib._bootstrap>", line 1058, in _handle_fromlist
  File "<frozen importlib._bootstrap>", line 228, in _call_with_frames_removed
  File "<frozen importlib._bootstrap>", line 1007, in _find_and_load
  File "<frozen importlib._bootstrap>", line 986, in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 680, in _load_unlocked
  File "<frozen importlib._bootstrap_external>", line 850, in exec_module
  File "<frozen importlib._bootstrap>", line 228, in _call_with_frames_removed
  File "/opt/conda/lib/python3.9/site-packages/text_generation_server/server.py", line 12, in <module>
    from text_generation_server.cache import Cache
  File "<frozen importlib._bootstrap>", line 1007, in _find_and_load
  File "<frozen importlib._bootstrap>", line 986, in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 680, in _load_unlocked
  File "<frozen importlib._bootstrap_external>", line 850, in exec_module
  File "<frozen importlib._bootstrap>", line 228, in _call_with_frames_removed
  File "/opt/conda/lib/python3.9/site-packages/text_generation_server/cache.py", line 3, in <module>
    from text_generation_server.models.types import Batch
  File "<frozen importlib._bootstrap>", line 1007, in _find_and_load
  File "<frozen importlib._bootstrap>", line 972, in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 228, in _call_with_frames_removed
  File "<frozen importlib._bootstrap>", line 1007, in _find_and_load
  File "<frozen importlib._bootstrap>", line 986, in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 680, in _load_unlocked
  File "<frozen importlib._bootstrap_external>", line 850, in exec_module
  File "<frozen importlib._bootstrap>", line 228, in _call_with_frames_removed
> File "/opt/conda/lib/python3.9/site-packages/text_generation_server/models/__init__.py", line 56, in <module>
    raise ImportError("CUDA is not available")
ImportError: CUDA is not available
 rank=0
2023-07-05T19:53:56.977961Z  INFO text_generation_launcher: Waiting for shard 0 to be ready...
2023-07-05T19:54:06.990582Z  INFO text_generation_launcher: Waiting for shard 0 to be ready...
2023-07-05T19:54:17.003345Z  INFO text_generation_launcher: Waiting for shard 0 to be ready...
2023-07-05T19:54:27.015806Z  INFO text_generation_launcher: Waiting for shard 0 to be ready...
2023-07-05T19:54:37.026669Z  INFO text_generation_launcher: Waiting for shard 0 to be ready...
2023-07-05T19:54:48.929366Z  INFO text_generation_launcher: Waiting for shard 0 to be ready...
2023-07-05T19:55:01.639136Z  INFO text_generation_launcher: Waiting for shard 0 to be ready...
2023-07-05T19:55:20.845415Z  INFO text_generation_launcher: Waiting for shard 0 to be ready...
2023-07-05T19:55:21.347050Z ERROR text_generation_launcher: Shard process was signaled to shutdown with signal 9
2023-07-05T19:55:21.362497Z ERROR text_generation_launcher: Shard 0 failed to start
2023-07-05T19:55:21.362749Z ERROR text_generation_launcher: /opt/conda/lib/python3.9/site-packages/bitsandbytes/cextension.py:33: UserWarning: The installed version of bitsandbytes was compiled without GPU support. 8-bit optimizers, 8-bit multiplication, and GPU quantization are unavailable.
  warn("The installed version of bitsandbytes was compiled without GPU support. "

2023-07-05T19:55:21.362864Z  INFO text_generation_launcher: Shutting down shards
Error: ShardCannotStart
ERROR: 1

```

# VSCode Extension

There are two options:
