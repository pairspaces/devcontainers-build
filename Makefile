.PHONY: deploy
deploy:
	devcontainer features publish -r ghcr.io -n pairspaces/devcontainers-build ./src --log-level trace

.PHONY: test
test:
	devcontainer features test --features pairspaces --project-folder .
