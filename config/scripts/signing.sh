#!/usr/bin/bash

set -oue pipefail

echo "Setting up container signing in policy.json and cosign.yaml for $IMAGE_NAME"
echo "Registry to write: $IMAGE_REGISTRY"

PKI_DIR=/usr/etc/pki/containers/
mkdir -p $PKI_DIR
cp /usr/share/ublue-os/cosign.pub "$PKI_DIR$IMAGE_NAME".pub

POLICY_JSON=/etc/containers/policy.json

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

IMAGE_REF="ostree-image-signed:docker://$IMAGE_REGISTRY/$IMAGE_NAME"
printf '{\n"image-ref": "'"$IMAGE_REF"'",\n"image-tag": "latest"\n}' > /usr/share/ublue-os/image-info.json

cp /usr/etc/containers/registries.d/ublue-os.yaml /usr/etc/containers/registries.d/"$IMAGE_NAME".yaml
sed -i "s ghcr.io/ublue-os $IMAGE_REGISTRY g" /usr/etc/containers/registries.d/"$IMAGE_NAME".yaml