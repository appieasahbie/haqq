# Haqq Testnet Tutorial 


![haqq](https://user-images.githubusercontent.com/108979536/196060554-89668464-d342-4258-b9cf-0c27d3af3f78.jpeg)



# Hardware Requirements
 
  ### Minimum Hardware Requirements
   + 4x CPUs; the faster clock speed the better
   + 8GB RAM
   + 100GB of storage (SSD or NVME)
   
 ###  Recommended Hardware Requirements
   + 8x CPUs; the faster clock speed the better
   + 64GB RAM
   + 1TB of storage (SSD or NVME)
   
### Lets Start

### for quick installation use our script

           wget -O haqq.sh https://raw.githubusercontent.com/appieasahbie/haqq/main/haqq.sh && chmod +x haqq.sh && ./haqq.sh


### Post installation
 
    source $HOME/.bash_profile
    
    
+ Check the status of your validator node

      haqqd status 2>&1 | jq .SyncInfo


### open ports and active the firewall

      sudo ufw default allow outgoing
      sudo ufw default deny incoming
      sudo ufw allow ssh/tcp
      sudo ufw limit ssh/tcp
      sudo ufw allow ${HAQQ_PORT}656,${HAQQ_PORT}660/tcp
      sudo ufw enable
      
 (Active the firewall)
 
     sudo ufw enable 
     
###   Data snapshot (optional)

     
     sudo systemctl stop haqqd
     rm -rf $HOME/.haqqd/data/
     mkdir $HOME/.haqqd/data/
    
     cd $HOME
     wget http://88.198.34.226:7150/haqqddata.tar.gz

     tar -C $HOME/ -zxvf haqqddata.tar.gz --strip-components 1
     wget -O $HOME/.haqqd/data/priv_validator_state.json "https://raw.githubusercontent.com/obajay/StateSync-snapshots/main/Canto/priv_validator_state.json"
     cd && cat .haqqd/data/priv_validator_state.json

     cd $HOME
     rm haqqddata.tar.gz
     systemctl restart haqqd && journalctl -u haqqd -f -o cat
     
###   Create wallet

   +  (Please save all keys on your notepad)
   
   
            haqqd keys add $WALLET
            
   +  (if you have old wallet recover it with this command)
   
   
            haqqd keys add $WALLET --recover
            
            
   ###   Add wallet and valoper address into variables 
   
           HAQQ_WALLET_ADDRESS=$(haqqd keys show $WALLET -a)
           HAQQ_VALOPER_ADDRESS=$(haqqd keys show $WALLET --bech val -a)
           echo 'export HAQQ_WALLET_ADDRESS='${HAQQ_WALLET_ADDRESS} >> $HOME/.bash_profile
           echo 'export HAQQ_VALOPER_ADDRESS='${HAQQ_VALOPER_ADDRESS} >> $HOME/.bash_profile
           source $HOME/.bash_profile
           
 ### Fund your wallet(tokens to became a validator)
 
 
           https://testedge2.haqq.network/

(after funding check your bank balance with the command bellow )


           haqqd query bank balances $HAQQ_WALLET_ADDRESS
           
           
 ### Create validator
 
 
           haqqd tx staking create-validator \
           --amount 100000000aISLM \
           --from $WALLET \
           --commission-max-change-rate "0.01" \
           --commission-max-rate "0.2" \
           --commission-rate "0.07" \
           --min-self-delegation "1" \
           --pubkey  $(haqqd tendermint show-validator) \
           --moniker $NODENAME \
           --chain-id $HAQQ_CHAIN_ID
           
           
 ###  Monitoring
    
    
   ### Check your validator key
   
        [[ $(haqqd q staking validator $HAQQ_VALOPER_ADDRESS -oj | jq -r .consensus_pubkey.key) = $(haqqd status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
        
   ### Get list of validators
   
        haqqd q staking validators -oj --limit=3000 | jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' | jq -r '(.tokens|tonumber/pow(10; 6)|floor|tostring) + " \t " + .description.moniker' | sort -gr | nl
        
   ###  Get currently connected peer list with ids
   
        curl -sS http://localhost:${HAQQ_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
        
 ###  Service management
   
   
   + Check logs

          journalctl -fu haqqd -o cat
          
          
      ### Start service

          sudo systemctl start haqqd
          
          
      ### Stop service

          sudo systemctl stop haqqd
          
          
      ### Restart service

          sudo systemctl restart haqqd
          
 ### Node info
      
   + Synchronization info


          haqqd status 2>&1 | jq .SyncInfo
      
      
   + Validator info
 
          haqqd status 2>&1 | jq .ValidatorInfo
          
          
      ### Node info

          haqqd status 2>&1 | jq .NodeInfo
          
          
      ### Show node id


          haqqd tendermint show-node-id
          
#### Wallet operations


   + List of wallets

          haqqd keys list




### Staking, Delegation and Rewards


  + Delegate stake

          haqqd tx staking delegate $HAQQ_VALOPER_ADDRESS 10000000aISLM --from=$WALLET --chain-id=$HAQQ_CHAIN_ID --gas=auto
          
          
     ### Redelegate stake from validator to another validator

          haqqd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000aISLM --from=$WALLET --chain-id=$HAQQ_CHAIN_ID --gas=auto
          
          
     ### Withdraw all rewards

          haqqd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$HAQQ_CHAIN_ID --gas=auto
          
          
     ### Withdraw rewards with commision

         haqqd tx distribution withdraw-rewards $HAQQ_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$HAQQ_CHAIN_ID


            
