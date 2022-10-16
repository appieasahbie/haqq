### Migrate your validator to another server

1. Run a new full node on a new server
To setup full node you can follow my guide haqq node setup for testnet

+ Confirm that you have the recovery seed phrase information for the active key running on the old machine
To backup your key

         haqqd keys export mykey

(This prints the private key that you can then paste into the file mykey.backup)

To get list of keys

        haqqd keys list
        
        
+ Recover the active key of the old machine on the new server

This can be done with the mnemonics

       haqqd keys add mykey --recover
       
       
Or with the backup file mykey.backup from the previous step


       haqqd keys import mykey mykey.backup
       
       
+ Wait for the new full node on the new machine to finish catching-up

(To check synchronization status)

       haqqd status 2>&1 | jq .SyncInfo
       
       
(catching_up should be equal to false)

+ After the new node has caught-up, stop the validator node


To prevent double signing, you should stop the validator node before stopping the new full node to ensure the new node is at a greater block height than the validator node If the new node is behind the old validator node, then you may double-sign blocks

### Stop and disable service on old machine

       sudo systemctl stop haqqd
       sudo systemctl disable haqqd
       
The validator should start missing blocks at this point

+ Stop service on new machine

       sudo systemctl stop haqqd
       
       
+ Move the validator's private key from the old machine to the new machine


(Private key is located in: ~/.haqqd/config/priv_validator_key.json)

After being copied, the key priv_validator_key.json should then be removed from the old node's config directory to prevent double-signing if the node were to start back up

       sudo mv ~/.haqqd/config/priv_validator_key.json ~/.haqqd/bak_priv_validator_key.json
       
       
+ Start service on a new validator node

        sudo systemctl start haqqd
      
      
The new node should start signing blocks once caught-up

+ Make sure your validator is not jailed

(To unjail your validator)

       haqqd tx slashing unjail --chain-id $HAQQ_CHAIN_ID --from mykey --gas=auto -y
