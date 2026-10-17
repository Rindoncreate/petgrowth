#!/usr/bin/env bash
set -euo pipefail

# Vercel's build image does not bundle MoonBit.
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash -s latest
export PATH="$HOME/.moon/bin:$PATH"
moon version --all
node scripts/build.mjs
