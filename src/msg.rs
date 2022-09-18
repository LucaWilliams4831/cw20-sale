use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use cosmwasm_std::{Addr, Coin, Uint128};

use cw20::Cw20ReceiveMsg;

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct InstantiateMsg {
    pub cw20_address: Addr,
    pub denom: String,
    pub price: Uint128,
    pub maxamount: Uint128,
    pub owner: Addr
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum ExecuteMsg {
    SetPrice { denom: String, price: Uint128 },
    SetMax {amount: Uint128},
    Buy { denom: String, price: Uint128 },
    WithdrawAll {},
    Receive(Cw20ReceiveMsg),
    UpdateConfig {address: Addr}
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub enum ReceiveMsg {
    Receive {},
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum QueryMsg {
    // GetCount returns the current count as a json-encoded number
    GetInfo {},
}

// We define a custom struct for each query response
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct InfoResponse {
    pub owner: Addr,
    pub cw20_address: Addr,
    pub price: Coin,
    pub balance: Uint128,
    pub sellamount: Uint128,
    pub maxamount: Uint128
}
