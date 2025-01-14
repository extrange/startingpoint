#!/usr/bin/env bash

set -oue pipefail

echo "Setting up container signing in policy.json and cosign.yaml for $IMAGE_NAME"
echo "Registry to write: $IMAGE_REGISTRY"

PKI_DIR=/usr/etc/pki/containers/
mkdir -p $PKI_DIR
cp /usr/share/ublue-os/cosign.pub "$PKI_DIR$IMAGE_NAME".pub

# For an explanation of what policy.json does, see
# https://github.com/containers/image/blob/main/docs/containers-policy.json.5.md
POLICY_JSON=/usr/etc/containers/policy.json # copied over via Files module

# This allows for signed updates (the default is insecureAcceptAnything, which does not perform verification and will therefore not allow ostree-image-signed containers.).
yq -i -o=j '.transports.docker |=
    {"'"$IMAGE_REGISTRY"'/'"$IMAGE_NAME"'": [
            {
                "type": "sigstoreSigned",
                "keyPath": "/etc/pki/containers/'"$IMAGE_NAME"'.pub",
                "signedIdentity": {
                    "type": "matchRepository"
                }
            }
        ]
    }
+ .' "$POLICY_JSON"

IMAGE_REF="ostree-image-signed:docker://$IMAGE_REGISTRY/$IMAGE_NAME"
printf '{\n"image-ref": "'"$IMAGE_REF"'",\n"image-tag": "latest"\n}' > /usr/share/ublue-os/image-info.json
