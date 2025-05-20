build:
	@rm -f result
	nix-build docker.nix
	docker load < result

run:
	docker run -p 8080:80 --rm application
