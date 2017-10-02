## FortySevenTokenCrowdsale.sol

This smart contract is written by *Fourty Seven* based on Zepplin-solidity.

Zepplin-solidity is well audited and tested set of opensource contracts, avaliable here https://github.com/OpenZeppelin/zeppelin-solidity.

Zepplin-solidity is following the best practicas of writing smart contracts(https://github.com/ConsenSys/smart-contract-best-practices) as well as main solidity security considerations (http://solidity.readthedocs.io/en/latest/security-considerations.html

This smart contract is specially designed to provide a limited emision of ERC20 (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md) standard tokens named **FSBT** (**Fourty Seven Token**) during pre-sale and main-sale periods of an ICO.

![](https://bitbucket.org/fortysevenbank/fsbt-smart-contract/raw/master/ico-scheme.png)

-------

## ERC20 FSBT Token Contract (based on Zepplin-solidity MintableToken)

  - Contract name **FSBToken**
  - Name **Forty Seven Bank Token**
  - Symbol **FSBT**
  - Decimals **18**

--------

## Crowdsale Contract

### Constructor

- *uint256* `preSaleStartTime`  start timestamp (in seconds) when pre-investments are allowed (inclusive)
- *uint256* `preSaleEndTime`    end timestamp (in seconds) when pre-investments are allowed (inclusive)
- *uint256* `preSaleWeiCap`     maximum amount of Wei that can be minted during pre-sale period
- *uint256* `mainSaleStartTime` start timestamp (in seconds) when main investments are allowed (inclusive)
- *uint256* `mainSaleEndTime`   end timestamp (in seconds) when main investments are allowed (inclusive)
- *uint256* `mainSaleWeiCap`    maximum amout of Wei that can be minted during main-sale period
- *address* `wallet`            address where the contract collects the ether, as well as where 10% of owners FSBT tokens will be collected after crowdsale finalization
- *uint256* `rate`              how many token units a buyer gets per 1 wei

### 2 Ways to buy tokens

There are 2 ways that allow to buy tokens

1. **Call public method `buyTokens`** and pass the ether as well as the address off the wallet where you want to collect FSBT tokens.
2. **Send ether to the contract address**. In this case FSBT tokens will be added to the sender's address.

### Bonuses (example)

The contract has a `rate` of 200 tokens per 1 ether.
You are sending to the contract the amount of 10 Ether during pre-sale period (expected 30% bonus).
You'll get `( 10 * 200 ) * ((100 + 30) / 100) = 2600 FSBT`

### Finalisation

The contract creator are allowed to finalize sales with the public method `finaliseCrowdsale`.

*This method fixes the whole amount of minted tokens `token.totalSupply` as **90%** and mint **10%** more tokens, for the address `wallet`. Then it forever stops minting of this token (means, stopping emission)

---------

## Important

The code of the contract as well as this readme.md will be updated few times before the beginning of the ICO.
We are focused on deep audit and testing, that may require minor changes.

-----------