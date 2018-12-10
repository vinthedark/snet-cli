# service side
# check how snet-cli works if we pass contract address via command line interface

# remove networks
rm -rf ../../snet_cli/resources/contracts/networks/*.json

#unset addresses
snet unset current_singularitynettoken_at || echo "could fail if hasn't been set (it is ok)"
snet unset current_registry_at  || echo "could fail if hasn't been set (it is ok)"
snet unset current_multipartyescrow_at || echo "could fail if hasn't been set (it is ok)"


# now snet-cli will work only if we pass contract addresses as commandline arguments

# this should fail without addresses
snet client balance && exit 1 || echo "fail as expected"
snet organization create testo -y -q  && exit 1 || echo "fail as expected"


snet service metadata_init ./service_spec1/ ExampleService 0x42A605c07EdE0E1f648aB054775D6D4E38496144  --encoding json --service_type jsonrpc --group_name group1 --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e
snet service metadata_add_group group2 0x0067b427E299Eb2A4CBafc0B04C723F77c6d8a18
snet service metadata_add_endpoints  8.8.8.8:2020 9.8.9.8:8080 --group_name group1
snet service metadata_add_endpoints  8.8.8.8:22   1.2.3.4:8080 --group_name group2
snet service metadata_set_fixed_price 0.0001
IPFS_HASH=$(snet service publish_in_ipfs)
ipfs cat $IPFS_HASH > service_metadata2.json

# compare service_metadata.json and service_metadata2.json
cmp <(jq -S . service_metadata.json) <(jq -S . service_metadata2.json)

snet organization create testo -y -q --registry-at 0x4e74fefa82e83e0964f0d9f53c68e03f7298a8b2
snet service publish testo tests -y -q --registry-at 0x4e74fefa82e83e0964f0d9f53c68e03f7298a8b2
snet service update_add_tags testo tests tag1 tag2 tag3 -y -q --registry-at 0x4e74fefa82e83e0964f0d9f53c68e03f7298a8b2
snet service update_remove_tags testo tests tag2 tag1 -y -q --registry-at 0x4e74fefa82e83e0964f0d9f53c68e03f7298a8b2
snet service print_tags  testo tests --registry-at 0x4e74fefa82e83e0964f0d9f53c68e03f7298a8b2
snet organization list --registry-at 0x4e74fefa82e83e0964f0d9f53c68e03f7298a8b2
# it should have only tag3 now
cmp <(echo "tag3") <(snet service print_tags testo tests --registry-at 0x4e74fefa82e83e0964f0d9f53c68e03f7298a8b2)

snet service print_metadata  testo tests --registry-at 0x4e74fefa82e83e0964f0d9f53c68e03f7298a8b2 |grep -v "We must check that hash in IPFS is correct" > service_metadata3.json

# compare service_metadata.json and service_metadata3.json
cmp <(jq -S . service_metadata.json) <(jq -S . service_metadata3.json)

# client side
snet client balance --snt 0x6e5f20669177f5bdf3703ec5ea9c4d4fe3aabd14 --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e
snet client deposit 12345 -y -q --snt 0x6e5f20669177f5bdf3703ec5ea9c4d4fe3aabd14 --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e
snet client transfer 0x0067b427E299Eb2A4CBafc0B04C723F77c6d8a18 42 -y -q --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e
snet client withdraw 1 -y -q --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e
snet client open_init_channel_metadata 42 1 --group_name group1 -y  -q --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e
snet client channel_claim_timeout 0 -y -q  --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e
snet client channel_extend_add 0 --expiration 10000 --amount 42 -y  -q  --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e
snet client open_init_channel_registry  testo tests 1 1000000  --group_name group2 -y -q  --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e --registry 0x4e74fefa82e83e0964f0d9f53c68e03f7298a8b2
snet client print_initialized_channels --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e
snet client print_all_channels --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e
rm -rf ~/.snet/mpe_client/
snet client init_channel_metadata 0 --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e
snet client init_channel_registry testo tests 1  --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e --registry 0x4e74fefa82e83e0964f0d9f53c68e03f7298a8b2
snet client print_initialized_channels --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e
snet client print_all_channels --mpe 0x5c7a4290f6f8ff64c69eeffdfafc8644a4ec3a4e
snet service delete testo tests -y -q --registry-at 0x4e74fefa82e83e0964f0d9f53c68e03f7298a8b2
snet organization list-services testo --registry-at 0x4e74fefa82e83e0964f0d9f53c68e03f7298a8b2
