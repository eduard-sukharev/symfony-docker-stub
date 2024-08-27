.PHONY: help
help::
	@echo "-----------$(lastword $(MAKEFILE_LIST))-----------"
	@grep -hE '^[a-zA-Z_-]+:.*? ### .*$$' $(lastword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?### "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install_certgen
install_certgen: ### Installs certgen to ./tools directory
ifeq (,$(wildcard tools/certgen))
	curl -Lk -O https://github.com/minio/certgen/releases/download/v1.2.1/certgen-linux-amd64
	mv -f certgen-linux-amd64 tools/certgen
	chmod +x tools/certgen
endif
	echo "Certgen installed"
