#!/usr/bin/bash

set -oue pipefail

echo "Setting up container signing in policy.json and cosign.yaml for $IMAGE_NAME"
echo "Registry to write: $IMAGE_REGISTRY"

PKI_DIR=/usr/etc/pki/containers/
mkdir -p $PKI_DIR
cp /usr/share/ublue-os/cosign.pub "$PKI_DIR$IMAGE_NAME".pub

# For an explanation of policy.json, see
# https://github.com/containers/image/blob/main/docs/containers-policy.json.5.md
POLICY_JSON=/etc/containers/policy.json

# This allows for signed updates (the default is insecureAcceptAnything, which does not perform verification).
yq -i -o=j '.transports.docker |=
    {"'"$IMAGE_REGISTRY"'/'"$IMAGE_NAME"'": [
            {
                "type": "sigstoreSigned",
                "keyPath": "/usr/etc/pki/containers/'"$IMAGE_NAME"'.pub",
                "signedIdentity": {
                    "type": "matchRepository"
                }
            }
        ]
    }
+ .' "$POLICY_JSON"

# rpm-ostree checks the upstream image's /usr/etc/containers/policy.json
cp $POLICY_JSON /usr/etc/containers/policy.json

IMAGE_REF="ostree-image-signed:docker://$IMAGE_REGISTRY/$IMAGE_NAME"
printf '{\n"image-ref": "'"$IMAGE_REF"'",\n"image-tag": "latest"\n}' > /usr/share/ublue-os/image-info.json
