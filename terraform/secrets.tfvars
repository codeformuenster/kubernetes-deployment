scaleway_organization = "b6650c75-c610-4d05-bfec-adfadd51063c"
scaleway_token = "94306fb3-7335-4b55-99a8-cd44d528ea0f"

# openssl rand -base64 32
weave_password = "mgBfWDDKXN1jzcYIQT/gfmfnvco2Y2WD2a9sVVGBcBA="

# https://groups.google.com/d/msg/kubernetes-sig-cluster-lifecycle/WjqA6mV5Hgg/-n4vXtX1AwAJ
# format “[a-z0-9]{6}.[a-z0-9]{16}“
#
# python -c 'import random; print "%0x.%0x" % (random.SystemRandom().getrandbits(3*8), random.SystemRandom().getrandbits(8*8))'
# openssl rand -hex 6; openssl rand -hex 16
# kubeadm token generate

# kubeadm_token = "yb7sqf.46a5dsyrqqyipj8k"
