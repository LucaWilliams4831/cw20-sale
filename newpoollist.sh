

#!/bin/bash

#Build Flag
PARAM=$1

####################################    Constants    ##################################################

#depends on mainnet or testnet
NODE="--node https://rpc.junomint.com:443"
CHAIN_ID=juno-1
DENOM="ujuno"

# • MARBLE-BLOCK
# • BLOCK-ATOM
# • BLOCK-UST
# • BLOCK-LUNA
# • BLOCK-SCRT
# • BLOCK-NETA
# • BLOCK-OSMO

#not depends
NODECHAIN=" $NODE --chain-id $CHAIN_ID"
TXFLAG=" $NODECHAIN --gas-prices 0.03$DENOM --gas auto --gas-adjustment 1.3"
WALLET="--from workshop"

ADDR_WORKSHOP="juno1htjut8n7jv736dhuqnad5mcydk6tf4ydeaan4s"

LP_TOKEN_CODE_ID=1
SWAP_CODE_ID=16

###################################################################################################
###################################################################################################
###################################################################################################
###################################################################################################
#Environment Functions

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
    junod query wasm list-contract-by-code $SWAP_CODE_ID $NODECHAIN --help

}

QuerySwapContract() {
    CONTRACT_ADDR="juno1hcsuhvxtygxg8gcrdxmzen2wmywf8sqpjgh0mxn3asz0e8na58vq2e4hls"
    junod query wasm contract-state smart $CONTRACT_ADDR '{"info":{}}' $NODECHAIN
}

CreateSwap2() {
    echo "================================================="
    echo "Instantiate Pool Contract"

    #Already done scripts(Maybe swap token1 and token2 required.)
    #junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"native":"ujuno"}, "token2_denom":{"cw20":"'$TOKEN_MARBLE'"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "MARBLE-JUNO"  $WALLET $TXFLAG -y
    #junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"native":"ujuno"}, "token2_denom":{"cw20":"'$TOKEN_BLCK'"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "BLCK-JUNO"  $WALLET $TXFLAG -y
    #Already Created Pools    
    #MARBLE-JUNO: juno1zsws7uhe2cz89qsu70ncuv33aemsc2szmld97mx2yy8gkx7fld6q04kmyd
    #BLCK-JUNO:juno1d6xs8za2z7r8jnjpev9valt6gmj69ggphj9n8930g8rz2mrfde0spnppdj

    #generated LP Tokens by CreateSwap
    #MARBLE-JUNO LP: juno1jqzxrr9n77r4jmve9lj3gwgmcasnv0p3awf39lm7eypm4hnw87csnhkemx
    #BLCK-JUNO LP: juno1cmmpty2dgs9h36vtrwxk53pmkwe3fgn5833wpay4ap0unm6svgks7aajke

    #The pools to create
    # • MARBLE-BLOCK
    # • BLOCK-ATOM
    # • BLOCK-UST
    # • BLOCK-LUNA
    # • BLOCK-SCRT
    # • BLOCK-NETA
    # • MARBLE-NETA
    # • BLOCK-OSMO

    MARBLE="juno1g2g7ucurum66d42g8k5twk34yegdq8c82858gz0tq2fc75zy7khssgnhjl"
    BLOCK="juno1w5e6gqd9s4z70h6jraulhnuezry0xl78yltp5gtp54h84nlgq30qta23ne"
    NETA="juno168ctmpyppk90d34p3jjy658zf5a5l3w8wk35wht6ccqj4mr0yv8s4j5awr"
    HLL="juno10dvlms4m555jk67qsrun5a87cn9gje967yl8hn5senjxlycdv37sqqukrn"

    # denom: 
    ATOM="ibc/C4CFF46FD6DE35CA4CF4CE031E643C8FDC9BA4B99AE598E9B0ED98FE3A2319F9"
    UST="ibc/2DA4136457810BCB9DAAB620CA67BC342B17C3C70151CA70490A170DF7C9CB27"
    LUNA="ibc/8F865D9760B482FF6254EDFEC1FF2F1273B9AB6873A7DE484F89639795D73D75"
    SCRT="ibc/B55B08EF3667B0C6F029C2CC9CAA6B00788CF639EBB84B34818C85CBABA33ABD"
    OSMO="ibc/ED07A3391A112B175915CD8FAF43A2DA8E4790EDE12566649D0C2F97716B8518"
    

    # • MARBLE-BLOCK : juno1ujsvmr9q0uj7rspj6epwtssuftd8zxxelxr3qh6v6ld77esv6jyshdjzau
    # • BLOCK-ATOM : juno1qr69r7g50978yhjpgdgdt2cjnqnp98xk0tte6mds2c4sff2rmtdsv4tyrh
    # • BLOCK-UST : juno1kqqt4vazysym6v3vdq9ws5zxzk8y2zcgpxrf2g5efresvq9y3ujsupt82e
    # • BLOCK-LUNA : juno1hlfdjvc6sv0thj9tz7686jg9u2yzu6vw49439weguuhkw9rkj6hqa58ru6
    # • BLOCK-SCRT : juno1jkwpfmmqvrgzvhk86hnerxnns6qefa667654qgnjmxhtwrxxzq8swwwxfx
    # • BLOCK-NETA : juno1whfwhda5nxmyng95jsw7782a92cduh3698v9fkp57qv67qm4s78svyx6pd
    # • MARBLE-NETA : juno16x2qr82cfpwn6asgcv4csulhuheqhm2jkv2vedz4uawgqnvdnazs50tvwf
    # • BLOCK-OSMO : juno1gmtxzulcql0g8905px3l2z8065d70ua4c03mu3z03e9a0yz7vuss8xgzxx
    
    # • MARBLE-BLOCK
    #junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"cw20":"'$MARBLE'"}, "token2_denom":{"cw20":"'$BLOCK'"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "MARBLE-BLOCK"  $WALLET $TXFLAG -y
    # # • BLOCK-ATOM
    #junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"cw20":"'$BLOCK'"}, "token2_denom":{"native":"'$ATOM'"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "BLOCK-ATOM"  $WALLET $TXFLAG -y
    # # • BLOCK-UST
    #junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"cw20":"'$BLOCK'"}, "token2_denom":{"native":"'$UST'"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "BLOCK-UST"  $WALLET $TXFLAG -y
    # # • BLOCK-LUNA
    #junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"cw20":"'$BLOCK'"}, "token2_denom":{"native":"'$LUNA'"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "BLOCK-LUNA"  $WALLET $TXFLAG -y
    # # • BLOCK-SCRT
    #junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"cw20":"'$BLOCK'"}, "token2_denom":{"native":"'$SCRT'"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "BLOCK-SCRT"  $WALLET $TXFLAG -y
    # # • BLOCK-NETA
    #junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"cw20":"'$BLOCK'"}, "token2_denom":{"cw20":"'$NETA'"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "BLOCK-NETA"  $WALLET $TXFLAG -y
    # # • MARBLE-NETA
    #junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"cw20":"'$MARBLE'"}, "token2_denom":{"cw20":"'$NETA'"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "MARBLE-NETA"  $WALLET $TXFLAG -y
    # # • BLOCK-OSMO
    #junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"cw20":"'$BLOCK'"}, "token2_denom":{"native":"'$OSMO'"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "BLOCK-OSMO"  $WALLET $TXFLAG -y
    
    #juno1wxgxsyjp2dupujtdzg7sw8eeqt0td07wy5qpsyttca2vu2crglkst7m2n7
    # # • JUNO-HLL
    #junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"native":"ujuno"}, "token2_denom":{"cw20":"'$HLL'"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "JUNO-HLL"  $WALLET $TXFLAG
    # junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"cw20":"'$HLL'"}, "token2_denom":{"native":"ujuno"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "JUNO-HLL Reverse"  $WALLET $TXFLAG -y
    # junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"cw20":"'$MARBLE'"}, "token2_denom":{"native":"ujuno"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "MARBLE-JUNO Reverse"  $WALLET $TXFLAG -y
    # junod tx wasm instantiate $SWAP_CODE_ID '{"token1_denom":{"cw20":"'$BLOCK'"}, "token2_denom":{"native":"ujuno"}, "lp_token_code_id": '$LP_TOKEN_CODE_ID'}' --label "BLOCK-JUNO Reverse"  $WALLET $TXFLAG -y
}
#################################### End of Function ###################################################
$PARAM

####################    Increase Allowance     #########################
# {
#   "increase_allowance": {
#     "spender": "juno1zsws7uhe2cz89qsu70ncuv33aemsc2szmld97mx2yy8gkx7fld6q04kmyd",
#     "amount": "100"
#   }
# }