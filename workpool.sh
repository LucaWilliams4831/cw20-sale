#!/bin/bash

#Build Flag
PARAM=$1

####################################    Constants    ##################################################

#depends on mainnet or testnet
NODE="--node https://rpc.junomint.com:443"
CHAIN_ID=juno-1
DENOM="ujuno"

TOKEN_MARBLE="juno1g2g7ucurum66d42g8k5twk34yegdq8c82858gz0tq2fc75zy7khssgnhjl"
TOKEN_BLCK="juno1w5e6gqd9s4z70h6jraulhnuezry0xl78yltp5gtp54h84nlgq30qta23ne"
# NODE="--node https://rpc.juno.giansalex.dev:443"
# #NODE="--node https://rpc.uni.junomint.com:443"
# CHAIN_ID=uni-2
# DENOM="ujunox"
# CONTRACT_VMARBLE="juno1j5rl5sy40nmlqyugphgh5hnyrmj2cc5h7swy9x8rm0jkxy566nlqcx0jmv"

#not depends
NODECHAIN=" $NODE --chain-id $CHAIN_ID"
TXFLAG=" $NODECHAIN --gas-prices 0.03$DENOM --gas auto --gas-adjustment 1.3"
WALLET="--from workshop"
WASMFILE="artifacts/wasmswap.wasm"

FILE_UPLOADHASH="uploadtx.txt"
FILE_SALE_CONTRACT_ADDR="contractaddr.txt"
FILE_CODE_ID="code.txt"

ADDR_WORKSHOP="juno1htjut8n7jv736dhuqnad5mcydk6tf4ydeaan4s"
ADDR_ADMIN="juno1ddcvnnq0puupr0f3cyq77ffmk32ylaxcd3ahjg"

LP_TOKEN_CODE_ID=1
SWAP_CODE_ID=16

###################################################################################################
###################################################################################################
###################################################################################################
###################################################################################################
#Environment Functions
CreateEnv() {
    sudo apt-get update && sudo apt upgrade -y
    sudo apt-get install make build-essential gcc git jq chrony -y
    wget https://golang.org/dl/go1.17.3.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.17.3.linux-amd64.tar.gz
    rm -rf go1.17.3.linux-amd64.tar.gz

    export GOROOT=/usr/local/go
    export GOPATH=$HOME/go
    export GO111MODULE=on
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    
    rustup default stable
    rustup target add wasm32-unknown-unknown

    git clone https://github.com/CosmosContracts/juno
    cd juno
    git fetch
    git checkout v2.1.0
    make install

    rm -rf juno

    junod keys import workshop workshop.key

}

#Contract Functions

#Build Optimized Contracts
OptimizeBuild() {

    echo "================================================="
    echo "Optimize Build Start"
    
    docker run --rm -v "$(pwd)":/code \
        --mount type=volume,source="$(basename "$(pwd)")_cache",target=/code/target \
        --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
        cosmwasm/rust-optimizer:0.12.4
}

RustBuild() {

    echo "================================================="
    echo "Rust Optimize Build Start"

    RUSTFLAGS='-C link-arg=-s' cargo wasm

    mkdir artifacts
    cp target/wasm32-unknown-unknown/release/sale.wasm $WASMFILE
}

#Writing to FILE_UPLOADHASH
Upload() {
    echo "================================================="
    echo "Upload $WASMFILE"
    
    UPLOADTX=$(junod tx wasm store $WASMFILE $WALLET $TXFLAG --output json -y | jq -r '.txhash')
    echo "Upload txHash:"$UPLOADTX
    
    #save to FILE_UPLOADHASH
    echo $UPLOADTX > $FILE_UPLOADHASH
    echo "wrote last transaction hash to $FILE_UPLOADHASH"
}

UploadTest() {
    echo "================================================="
    echo "Upload $WASMFILE"
    
    junod tx wasm store $WASMFILE $WALLET $TXFLAG --output json -y
    
}

#Read code from FILE_UPLOADHASH
GetCode() {
    echo "================================================="
    echo "Get code from transaction hash written on $FILE_UPLOADHASH"
    
    #read from FILE_UPLOADHASH
    TXHASH=$(cat $FILE_UPLOADHASH)
    echo "read last transaction hash from $FILE_UPLOADHASH"
    echo $TXHASH
    
    QUERYTX="junod query tx $TXHASH $NODECHAIN --output json"
	CODE_ID=$(junod query tx $TXHASH $NODECHAIN --output json | jq -r '.logs[0].events[-1].attributes[0].value')
	echo "Contract Code_id:"$CODE_ID

    #save to FILE_CODE_ID
    echo $CODE_ID > $FILE_CODE_ID
}

#Instantiate Contract
Instantiate() {
    echo "================================================="
    echo "Instantiate Contract"
    
    #read from FILE_CODE_ID
    CODE_ID=$(cat $FILE_CODE_ID)
    junod tx wasm instantiate $CODE_ID '{"cw20_address":"'$CONTRACT_VMARBLE'", "denom":"ujunox", "price":"100", "maxamount":"10"}' --label "vMarbleSale" $WALLET $TXFLAG -y
}

#Get Instantiated Contract Address
GetContractAddress() {
    echo "================================================="
    echo "Get contract address by code"
    
    #read from FILE_CODE_ID
    CODE_ID=$(cat $FILE_CODE_ID)
    CONTRACT_ADDR=$(junod query wasm list-contract-by-code $CODE_ID $NODECHAIN --output json | jq -r '.contracts[0]')
    
    echo "Contract Address : "$CONTRACT_ADDR

    #save to FILE_SALE_CONTRACT_ADDR
    echo $CONTRACT_ADDR > $FILE_SALE_CONTRACT_ADDR
}



###################################################################################################
###################################################################################################
#LP Token
CreateLPToken() {
    echo "================================================="
    echo "Instantiate LPToken Contract"
    
    junod tx wasm instantiate $LP_TOKEN_CODE_ID '{"name":"WasmSwap_Liquidity_Token", "symbol":"wslpt", "decimals":6, "initial_balances":[{"address":"'$ADDR_ADMIN'", "amount":"1000000"}]}' --label "lp_token"  $WALLET $TXFLAG -y
}

QueryLPTokenAddressList() {
    junod query wasm list-contract-by-code $LP_TOKEN_CODE_ID $NODECHAIN
}

QueryLPTokenContract() {
    CONTRACT_ADDR="juno1cmmpty2dgs9h36vtrwxk53pmkwe3fgn5833wpay4ap0unm6svgks7aajke"
    junod query wasm contract-state smart $CONTRACT_ADDR '{"token_info":{}}' $NODECHAIN
}
###################################################################################################
###################################################################################################
#Wallet
PrintWalletBalance() {
    junod query bank balances $ADDR_WORKSHOP $NODECHAIN
}
###################################################################################################
###################################################################################################
#Pool
CreateSwap() {
    echo "================================================="
    echo "Instantiate Pool Contract"
    
    #junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"native":"ujuno"}, "token2_denom":{"cw20":"'$TOKEN_MARBLE'"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "MARBLE-JUNO"  $WALLET $TXFLAG -y
    junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"native":"ujuno"}, "token2_denom":{"cw20":"'$TOKEN_BLCK'"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "BLCK-JUNO"  $WALLET $TXFLAG -y
}

QuerySwapAddressList() {
    junod query wasm list-contract-by-code $SWAP_CODE_ID $NODECHAIN
}

QuerySwapContract() {
    CONTRACT_ADDR="juno1hcsuhvxtygxg8gcrdxmzen2wmywf8sqpjgh0mxn3asz0e8na58vq2e4hls"
    junod query wasm contract-state smart $CONTRACT_ADDR '{"info":{}}' $NODECHAIN
}

QueryContract() {
    junod query wasm contract-state smart $2 '{"info":{}}' $NODECHAIN
}


#################################### End of Function ###################################################
$PARAM
#junod query wasm contract-state smart $2 '{"info":{}}' $NODECHAIN
#Manually Created LP Tokens
#LP Token 1 : juno15x03xukszhqyzgz5t2vw7g2uldadj0va2z4uyhmnukhnqy6lpm7scrkq9h
#LP Token 2 : juno1javclyu86lq00n4h5pj8ddc00atj9pclchwj9zy4xrx8qy9n59psza5ll6

#SWAP Addresses
#SWAP MARBLE-JUNO : juno1hcsuhvxtygxg8gcrdxmzen2wmywf8sqpjgh0mxn3asz0e8na58vq2e4hls
#SWAP BLCK-JUNO : juno1muw3wrnvx2a470pq642fql7p5h3lsv7tknun9lf8eterjzrderns9qqeqt

#generated LP Tokens by CreateSwap
#MARBLE-JUNO LP: juno14ztq7s3zamwskzefgepfv8cmsz6j0hk9pprqqcphmc47ht7gkkxqhxdncr
#BLCK-JUNO LP: juno1d0hprdwl4f6u926nmh8t3gxfep8mevtpacurc9dsyjkqg74c3xkqttj9ue
#===================================================================================

#SWAP Addresses by ujuno
#MARBLE-JUNO: juno1zsws7uhe2cz89qsu70ncuv33aemsc2szmld97mx2yy8gkx7fld6q04kmyd
#BLCK-JUNO:juno1d6xs8za2z7r8jnjpev9valt6gmj69ggphj9n8930g8rz2mrfde0spnppdj

#generated LP Tokens by CreateSwap
#MARBLE-JUNO LP: juno1jqzxrr9n77r4jmve9lj3gwgmcasnv0p3awf39lm7eypm4hnw87csnhkemx
#BLCK-JUNO LP: juno1cmmpty2dgs9h36vtrwxk53pmkwe3fgn5833wpay4ap0unm6svgks7aajke

