// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event BuyToken(uint256 amount);
}

contract BGToken is IERC20{
    using SafeMath for uint256;

    address  immutable creator;

    string public constant name= "BGTOKEN";
    string public constant symbol="BGT";
    uint8 public constant decimals=18;
    


    mapping(address =>uint256) balances;//this hold the token balance of each address 

    mapping(address=>mapping(address=>uint256)) allowed;//this holds the addresses allowed to withdraw from an address and the amount allowed

    uint256 totalSupply_;
    
    //store the total amount of token supplied to the address that created the contract.
    constructor (){
         creator= msg.sender;
        totalSupply_=1000000;
        balances[msg.sender]=totalSupply_;
    }

    //this returns the total amount of token in circulation 
    function totalSupply() public override view  returns (uint256){
        return totalSupply_;
    }

    //this returns the amount of token in a particular address
    function balanceOf(address holder) public override view returns(uint256){
        require(holder != address(0));
        return balances[holder];
    }

    //this transfers a particular amount of token from the the address invoking the function to a receiver address
    function transfer(address recipient,uint256 amount) public override returns(bool){
        require(recipient != address(0));
        require(balances[msg.sender]>=amount,"Insufficent balance");
        require(recipient != address(0));
        balances[msg.sender]=balances[msg.sender].sub(amount);
        balances[recipient]=balances[recipient].add(amount);
        payable(recipient).transfer(amount);
        emit Transfer(msg.sender,recipient,amount);
        return true;
    }

    //Approve an address to withdraw tokens from  your address
    function approve(address intermediary, uint256 amount) public override returns(bool){
        require(msg.sender== creator);
        require(intermediary != address(0));
        require(balances[msg.sender]>=amount,"Insufficent balance");
        require(intermediary !=address(0));
        allowed[msg.sender][intermediary]=amount;
        emit Approval(msg.sender,intermediary,amount);
        return true;
    }

    //Get the amount token approved by an address owner for an intermediary address to withdraw from the owner's account
    function allowance(address owner,address intermediary) public override view returns(uint256){
        require(owner !=address(0));
        require(intermediary != address(0));
        require(owner!=address(0));
        require(intermediary!=address(0));
        return allowed[owner][intermediary];

    } 

    // It allows the intermediary approved for withdrawal to transfer owner funds to a third-party account.
    function transferFrom(address owner,address recipient,uint amount)public override returns(bool){
        require(owner!=address(0));
        require(recipient != address(0));
        require(balances[owner]>=amount);
        require(allowed[owner][msg.sender]>=amount,"Insufficent balance");
        balances[owner]=balances[owner]-amount;
        allowed[owner][msg.sender]=allowed[owner][msg.sender]-amount;
        balances[recipient]=balances[recipient]+1;
        emit Transfer(owner,recipient,amount);
        return true;
    }

    //This allows an address to buy token and increase the total tokens in circulation
    function buyToken(address receiver) public payable  returns(uint256){
        require(receiver != address(0));  
        uint256 amount= (msg.value/10**18)*1000; 
        require(balances[receiver]<= totalSupply_);
        totalSupply_= totalSupply_+ amount;
        balances[receiver]= balances[receiver]+amount;
        emit BuyToken(amount);
        return totalSupply_;
    }




}