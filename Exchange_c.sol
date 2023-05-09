// SPDX-License-Identifier: UNLICENSED

/*

JB-1021-HW_2
Ouazghire Mohamed Mourad
m.ouazghire@constructor.university

*/
pragma solidity ^0.8.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract Exchange_Contract {

    address private owner;
    mapping (IERC20 => uint) private exchangeRate;
    mapping(IERC20 => bool) private isTokenAllowed;

    constructor() {
        owner = payable(msg.sender);
    }


    modifier onlyOwner(){
        require(msg.sender==owner, "Only owner can do this operation");
        _;
    }
    function allowToken(address _token) external {
        require(msg.sender == owner, "Tokens can only be possessed by contract owner");
        isTokenAllowed[IERC20(_token)] = true;
    }

    function isAllowed(address _token) external view returns (bool) {
        return isTokenAllowed[IERC20(_token)];
    }

    function getExchangeRate(address _token) external view returns (uint) {
        require(isTokenAllowed[IERC20(_token)], "Token can't be deposited as it is not supported in the contract");
        return exchangeRate[IERC20(_token)];
    }

    function getBalance(address _token) external view returns (uint) {
        require(isTokenAllowed[IERC20(_token)], "Token can't be deposited as it is not supported in the contract");
        return IERC20(_token).balanceOf(address(this));
    }


    function changeExchangeRate(address _token, uint _amount) external {
        require(msg.sender == owner, "Exchange rate can not be defined");
        require(isTokenAllowed[IERC20(_token)], "Token can't be deposited as it is not supported in the contract");
        exchangeRate[IERC20(_token)] = _amount;
    }

    function removeToken(address _token) onlyOwner external {
        isTokenAllowed[IERC20(_token)] = false;
    }

    function sellToken(address _token, uint _amount) public {
        require(_amount > 0, "Please give a proper number of tokens");
        require(isTokenAllowed[IERC20(_token)], "Token can't be deposited as it is not supported in the contract");
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "The transaction did not occur");
        require(address(this).balance >= exchangeRate[IERC20(_token)] * _amount, "Not enough wei to buy tokens");
        require(payable(msg.sender).send(exchangeRate[IERC20(_token)] * _amount), "The transaction did not occur");
    }

    function buyToken(address _token, uint _amount) public payable {
        require(_amount > 0, "One can't buy less than 1 token");
        require(isTokenAllowed[IERC20(_token)], "Token can't be deposited as it is not supported in the contract");
        require(exchangeRate[IERC20(_token)] * _amount >= msg.value);
        require(IERC20(_token).transferFrom(address(this), msg.sender, _amount), "The transaction did not occur");
    }
}