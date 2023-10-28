#!/bin/bash
echo -e "\033[0;35m"

echo "            ####         ##########  ##########  ####   #########";
echo "           ######        ###    ###  ###    ###  ####   #########";
echo "          ###  ###       ###    ###  ###    ###  ####   ##";
echo "         ##########      ##########  ##########  ####   ######";
echo "        ############     ####        ####        ####   ##";
echo "       ####      ####    ####        ####        ####   #########";
echo "      ####        ####   ####        ####        ####   #########";

echo -e '\e[36mTwitter:\e[39m' https://twitter.com/ABDERRAZAKAKRI3
echo -e '\e[36mGithub: \e[39m' https://github.com/appieasahbie
echo -e "\e[0m"



read -r -p "Enter node moniker: " NODE_MONIKER

CHAIN_ID="haqq_11235-1"
CHAIN_DENOM="aISLM"
BINARY_NAME="haqqd"
BINARY_VERSION_TAG="v1.6.2"
CHEAT_SHEET="https://github.com/appieasahbie/haqq"

printLine
echo -e "Node moniker:       ${CYAN}$NODE_MONIKER${NC}"
echo -e "Chain id:           ${CYAN}$CHAIN_ID${NC}"
echo -e "Chain demon:        ${CYAN}$CHAIN_DENOM${NC}"
echo -e "Binary version tag: ${CYAN}$BINARY_VERSION_TAG${NC}"
printLine
sleep 1

source <(curl -s https://raw.githubusercontent.com/nodejumper-org/cosmos-scripts/master/utils/dependencies_install.sh)

printCyan "4. Building binaries..." && sleep 1

cd $HOME
rm -rf haqq
git clone https://github.com/haqq-network/haqq.git
cd haqq
git checkout v1.6.2
make install

haqqd config keyring-backend test
haqqd config chain-id $CHAIN_ID
haqqd init "$NODE_MONIKER" --chain-id $CHAIN_ID

curl -Ls https://ss.haqq.nodestake.top/genesis.json > $HOME/.haqqd/config/genesis.json
curl -Ls https://ss.haqq.nodestake.top/addrbook.json > $HOME/.haqqd/config/addrbook.json

printCyan "5. Starting service and synchronization..." && sleep 1

sudo tee /etc/systemd/system/haqqd.service > /dev/null <<EOF
[Unit]
Description=haqqd Daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which haqqd) start
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF


haqqd tendermint unsafe-reset-all --home ~/.haqqd/ --keep-addr-book

SNAP_NAME=$(curl -s https://ss.haqq.nodestake.top/ | egrep -o ">20.*\.tar.lz4" | tr -d ">")
curl -o - -L https://ss.haqq.nodestake.top/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/.haqqd

sudo systemctl daemon-reload
sudo systemctl enable haqqd
sudo systemctl start haqqd

printLine
echo -e "Check logs:            ${CYAN}sudo journalctl -u $BINARY_NAME -f --no-hostname -o cat ${NC}"