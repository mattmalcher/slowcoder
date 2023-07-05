run_starcoder:
	docker-compose \
	-f ./infra/docker-compose.yml \
	run \
	-e HF_API_TOKEN=$$(secret-tool lookup api hf_read) \
	slowcoder
