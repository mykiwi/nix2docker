build:
	nix build .#docker-image
	docker load < result

run:
	docker run -p 8080:80 --rm php-app
