# syntax=docker/dockerfile:1
FROM nixos/nix:latest as base

ARG CACHE_NAME
ARG WORKDIR=/wrk

WORKDIR ${WORKDIR}

# Support new CLI and flakes
RUN echo "extra-experimental-features = nix-command flakes ca-derivations" >> /etc/nix/nix.conf

# Support Darwin hosts
RUN echo "filter-syscalls = false" >> /etc/nix/nix.conf

# Set up initial binary caches
RUN echo "substituters = https://cache.nixos.org/ https://nix-community.cachix.org" >> /etc/nix/nix.conf
RUN echo "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" >> /etc/nix/nix.conf

# Install Cachix CLI
RUN nix profile install github:NixOS/nixpkgs/nixpkgs-unstable#cachix

RUN cachix use ${CACHE_NAME}

COPY . ${WORKDIR}

FROM base as package
ARG FLAKE_ATTRIBUTE
RUN nix build -L .#${FLAKE_ATTRIBUTE}

FROM package as cache_package
RUN --mount=type=secret,id=cachix_token \
        nix-store -qR --include-outputs $(nix-store -qd $(nix build -L .#${FLAKE_ATTRIBUTE} --print-out-paths)) \
        | grep -v '\.drv$' \
        | CACHIX_AUTH_TOKEN=$(cat /run/secrets/cachix_token) cachix push ${CACHE_NAME}

# FROM package as dockerImage