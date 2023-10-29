#!/bin/bash
set -e

if [ ! -d "$CMTHOME/config" ]; then
	echo "Running cometbft init to create (default) configuration for docker run."
	cometbft init

	sed -i \
		-e "s/^proxy_app\s*=.*/proxy_app = \"$PROXY_APP\"/" \
		-e "s/^moniker\s*=.*/moniker = \"$MONIKER\"/" \
		-e 's/^addr_book_strict\s*=.*/addr_book_strict = false/' \
		-e 's/^target_height_duration\s*=.*/target_height_duration = "800ms"/' \
		-e 's/^post_target_buffer_duration\s*=.*/post_target_buffer_duration = "300ms"/' \
		-e 's/^index_all_tags\s*=.*/index_all_tags = true/' \
		-e 's,^laddr = "tcp://127.0.0.1:26657",laddr = "tcp://0.0.0.0:26657",' \
		-e 's/^prometheus\s*=.*/prometheus = true/' \
		"$CMTHOME/config/config.toml"

	jq ".chain_id = \"$CHAIN_ID\" | .consensus_params.block.time_iota_ms = \"500\"" \
		"$CMTHOME/config/genesis.json" > "$CMTHOME/config/genesis.json.new"
	mv "$CMTHOME/config/genesis.json.new" "$CMTHOME/config/genesis.json"
fi

exec cometbft "$@"
