# Lightweight packer: validate / push silentorb-agents packages via ORAS.
FROM alpine:3.20

ARG ORAS_VERSION=1.2.2

RUN apk add --no-cache bash curl jq ca-certificates \
  && curl -fsSL "https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_amd64.tar.gz" \
    | tar -xz -C /usr/local/bin oras \
  && chmod +x /usr/local/bin/oras

WORKDIR /work
COPY pack/pack.sh /usr/local/bin/pack-agents
RUN chmod +x /usr/local/bin/pack-agents

ENTRYPOINT ["/usr/local/bin/pack-agents"]
