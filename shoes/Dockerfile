FROM alpine:latest

RUN apk add --no-cache curl jq

RUN ARCH=$(uname -m) && \
    ASSET_NAME="shoes-${ARCH}-unknown-linux-musl.tar.gz" && \
    echo "Downloading ${ASSET_NAME}..." && \
    ASSET_URL=$(curl -sL "https://api.github.com/repos/cfal/shoes/releases/latest" \
        | jq -r --arg name "$ASSET_NAME" '.assets[] | select(.name == $name) | .browser_download_url') && \
    test -n "$ASSET_URL" || { echo "ERROR: Asset ${ASSET_NAME} not found"; exit 1; } && \
    curl -L "$ASSET_URL" -o /tmp/shoes.tar.gz && \
    mkdir -p /usr/local/bin && tar xzf /tmp/shoes.tar.gz -C /usr/local/bin && \
    rm /tmp/shoes.tar.gz

RUN chmod +x /usr/local/bin/shoes

CMD ["/usr/local/bin/shoes"]
