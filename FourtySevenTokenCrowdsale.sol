pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


contract FSToken is MintableToken {
  string public name = "Forty Seven Token";
  string public symbol = "FST";
  uint256 public decimals = 18;
}

/**
 * @title Crowdsale
 * @dev Modified contract for managing a token crowdsale.
 * FourtySevenTokenCrowdsale have pre-sale and main sale periods, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate and the system of bonuses.
 * Funds collected are forwarded to a wallet as they arrive.
 * pre-sale and main sale periods both have caps defined in tokens
 */

contract FourtySevenTokenCrowdsale {
  using SafeMath for uint256;

  // original contract creator
  address public contractCreator;

  // true for finalised crowdsale
  bool public isFinalised;

  // The token being sold
  MintableToken public token;

  // start and end timestamps where pre-investments are allowed (both inclusive)
  uint256 public preSaleStartTime;
  uint256 public preSaleEndTime;

  // start and end timestamps where main-investments are allowed (both inclusive)
  uint256 public mainSaleStartTime;
  uint256 public mainSaleEndTime;

  // maximum amout of token that can be minted during pre-sale and main sale
  uint256 public preSaleTokenCap;
  uint256 public mainSaleTokenCap;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event FinalisedCrowdsale(uint256 totalSupply, uint256 minterBenefit);

  function FourtySevenTokenCrowdsale(uint256 _preSaleStartTime, uint256 _preSaleEndTime, uint256 _preSaleTokenCap, uint256 _mainSaleStartTime, uint256 _mainSaleEndTime, uint256 _mainSaleTokenCap, uint256 _rate, address _wallet) {

    contractCreator = msg.sender;

    // can't start pre-sale in the past
    require(_preSaleStartTime >= now);

    // can't start main sale in the past
    require(_mainSaleStartTime >= now);

    // can't start main sale before the end of pre-sale
    require(_preSaleEndTime < _mainSaleStartTime);

    // the end of pre-sale can't happen before it's start
    require(_preSaleStartTime < _preSaleEndTime);

    // the end of main sale can't happen before it's start
    require(_mainSaleStartTime < _mainSaleEndTime);

    require(_rate > 0);
    require(_preSaleTokenCap > 0);
    require(_mainSaleTokenCap > 0);
    require(_wallet != 0x0);

    token = createTokenContract();
    preSaleStartTime = _preSaleStartTime;
    preSaleEndTime = _preSaleEndTime;
    preSaleTokenCap = _preSaleTokenCap;
    mainSaleStartTime = _mainSaleStartTime;
    mainSaleEndTime = _mainSaleEndTime;
    mainSaleTokenCap = _mainSaleTokenCap;
    rate = _rate;
    wallet = _wallet;
    isFinalised = false;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new FSToken();
  }

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) payable {
    require(!isFinalised);
    require(beneficiary != 0x0);
    require(msg.value != 0);

    bool withinPreSalePeriod = now >= preSaleStartTime && now <= preSaleEndTime;
    bool withinMainSalePeriod = now >= mainSaleStartTime && now <= mainSaleEndTime;

    require(withinPreSalePeriod || withinMainSalePeriod);

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // add bonus to tokens depends on the period
    uint256 bonusedTokens = applyBonus(tokens);

    uint256 totalSupply = token.totalSupply();
    uint256 expectedTotalSupply = totalSupply.add(bonusedTokens);

    if (withinPreSalePeriod) {require(expectedTotalSupply <= preSaleTokenCap);}
    if (withinMainSalePeriod) {require(expectedTotalSupply <= mainSaleTokenCap);}

    // update state
    weiRaised = weiRaised.add(weiAmount);
    token.mint(beneficiary, bonusedTokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, bonusedTokens);

    forwardFunds();
  }

  // finish crowdsale,
  // take totalSupply as 90% and mint 10% more to specified owner's wallet
  // then stop minting forever

  function finaliseCrowdsale() public returns (bool) {
    require(contractCreator == msg.sender);
    require(!isFinalised);
    uint256 totalSupply = token.totalSupply();
    uint256 minterBenefit = totalSupply.mul(10).div(90);
    token.mint(wallet, minterBenefit);
    token.finishMinting();
    FinalisedCrowdsale(totalSupply, minterBenefit);
    isFinalised = true;
    return true;
  }

  // send ether to the fund collection wallet
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if main sale event has ended
  function mainSaleHasEnded() public constant returns (bool) {
    return now > mainSaleEndTime;
  }

  // @return true if pre sale event has ended
  function preSaleHasEnded() public constant returns (bool) {
    return now > preSaleEndTime;
  }

  function getBonusPercent(uint256 tokens) internal constant returns (uint256 percent) {
    // production
    uint mainSalePeriod1 = 259200;  // 3days
    uint mainSalePeriod2 = 604800;  // 7
    uint mainSalePeriod3 = 1209600; // 14
    uint mainSalePeriod4 = 2419200; // 28

    uint mainSalePeriod4amount1 = 2500 ether; //15
    uint mainSalePeriod4amount2 = 500 ether;  //10
    uint mainSalePeriod4amount3 = 100 ether;  //5
    uint mainSalePeriod4amount4 = 10 ether;   //2.5

    bool isPreSale = now >= preSaleStartTime && now <= preSaleEndTime;
    bool isMainSale = now >= mainSaleStartTime && now <= mainSaleEndTime;

    if (isPreSale) {
      return 40; // 40% bonus during pre-sale
    } else if (isMainSale) {
      uint diffInSeconds = now - mainSaleStartTime;
      // main sale bonuses
      if (diffInSeconds <= mainSalePeriod1) {return 25;}                                    // 25% bonus during 1st main sale period
      if (diffInSeconds > mainSalePeriod1 && diffInSeconds <= mainSalePeriod2) {return 15;} // 15% bonus during 2nd main sale period
      if (diffInSeconds > mainSalePeriod2 && diffInSeconds <= mainSalePeriod3) {return 10;} // 10% bonus during 3rd main sale period
      if (diffInSeconds > mainSalePeriod3 && diffInSeconds <= mainSalePeriod4) {
        // main sale 4th period (bonus for the amount)
        if (tokens >= mainSalePeriod4amount1) {return 15;}
        if (tokens >= mainSalePeriod4amount2) {return 10;}
        if (tokens >= mainSalePeriod4amount3) {return 5;}
        if (tokens >= mainSalePeriod4amount4) {return 2;}
      }
    }
    return 0;
  }

  function applyBonus(uint256 tokens) internal constant returns (uint256 bonusedTokens) {
    uint256 percent = getBonusPercent(tokens);
    uint256 tokensToAdd = tokens.mul(percent).div(100);
    return tokens.add(tokensToAdd);
  }

}