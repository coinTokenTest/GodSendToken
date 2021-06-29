pragma solidity ^0.5.0;
import "./BasicTokenWithFees.sol";

contract GodSendToken is BasicTokenWithFees{
    constructor() public BasicTokenWithFees(){
        super._init("GodSendToken","GSTC",16,1*(10**16)*(10**16),1*(10**12)*(10**16));
        super._initFeeRate(50,30,20,10,false);
    }
}