pragma solidity ^0.5.0;
import "./BasicToken.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
contract BasicTokenWithFees is BasicToken{
    using SafeMath for uint256;
    uint256 internal FEE_RATE;
    uint256 internal _totalDestroyed;
    uint256 internal MIN_COIN_NUM;
    uint256 internal FEE_RATE_MILLION;
    uint256 internal FEE_RATE_BILLION;
    uint256 internal FEE_RATE_HUNDERED_BILLION;
    bool internal IS_ADD;
    constructor()public {

    }
    function _init(string memory name,string memory symbol,uint8 decimals,uint256 totalSupply,uint256 minCoinNum) internal {
        MIN_COIN_NUM = minCoinNum;
        super._init(name,symbol,decimals,totalSupply);
    }
    function _initFeeRate(uint256 feeRate,uint256 feeRateMillion,uint256 feeRateBillion,uint256 feeRateHundredBillion,bool isAdd) internal{
        FEE_RATE = feeRate;
        FEE_RATE_MILLION = feeRateMillion;
        FEE_RATE_BILLION = feeRateBillion;
        FEE_RATE_HUNDERED_BILLION = feeRateHundredBillion;
        IS_ADD = isAdd; 
    }
    function calculateFee(uint256 amount) internal view returns(uint256){
        uint256 fee = 0;
        if(_totalSupply > MIN_COIN_NUM || (IS_ADD && MIN_COIN_NUM > _totalSupply)){
            uint256 feeRate = FEE_RATE;
            if(amount >= 1*(10**12)*(10**uint256(decimals()))){
                feeRate = FEE_RATE_HUNDERED_BILLION;
            }else if(amount >= 1*(10**9)*(10**uint256(decimals()))){
                feeRate = FEE_RATE_BILLION;
            }else if(amount >=  1*(10**6)*(10**uint256(decimals()))){
                feeRate = FEE_RATE_MILLION;
            }
            fee = (amount.mul(feeRate)).div(1000);
        }
        return fee;
    }
    /**
    *see {IERC20-totalDestroyed}
    */
    function totalDestroyed() public view returns(uint256){
        return _totalDestroyed;
    }
    function ContractIsAdd() public view returns(bool){
        return IS_ADD;
    }
    function getMinCoinNum() public view returns(uint256){
        return MIN_COIN_NUM;
    }
    function transfer(address receiver,uint256 amount) public returns (bool){
        require(receiver != msg.sender);
        uint256 fee = calculateFee(amount);
        uint256 feeAmount = 0;
        if(IS_ADD){
            feeAmount = amount.add(fee);
        }else{
            feeAmount = amount.sub(fee);
        }
        super.transfer(receiver,feeAmount);
        if(IS_ADD){
            _totalDestroyed = _totalDestroyed.sub(fee);
            _totalSupply = _totalSupply.add(fee);  
        }else{
            _totalDestroyed = _totalDestroyed.add(fee);
            _totalSupply = _totalSupply.sub(fee); 
        }
    }

    function transferFrom(address sender,address receiver,uint256 amount) public returns(bool){
        require(sender != receiver);
        require(amount <= _allowances[sender][msg.sender]);
        require(amount > 0,"Transfer amount must be greater than zero");
        require(_balances[sender] >= amount,"Transfer amount exceeds the account's money");
        uint256 fee = calculateFee(amount);
        uint256 feeAmount = 0;
        if(IS_ADD){
            feeAmount = amount.add(fee);
        }else{
            feeAmount = amount.sub(fee);
        }
        _transfer(sender, receiver, feeAmount);
        if(IS_ADD){
            _totalDestroyed = _totalDestroyed.sub(fee);
            _totalSupply = _totalSupply.add(fee);  
        }else{
            _totalDestroyed = _totalDestroyed.add(fee);
            _totalSupply = _totalSupply.sub(fee); 
        }
        decreaseAllowance(sender,amount);
    }
    event FeeRateChanged(uint256 feeRate,uint256 feeRateMillion,uint256 feeRateBillion,uint256 feeRateHundredBillion,uint256 minCoinNum);
    function setFeeRate(uint256 feeRate,uint256 feeRateMillion,uint256 feeRateBillion,uint256 feeRateHundredBillion) public onlyOwner{
        require(feeRate>=0);
        require(feeRateMillion>=0);
        require(feeRateBillion>=0);
        require(feeRateHundredBillion>=0);
        FEE_RATE = feeRate;
        FEE_RATE_MILLION = feeRateMillion;
        FEE_RATE_BILLION = feeRateBillion;
        FEE_RATE_HUNDERED_BILLION = feeRateHundredBillion;
        emit FeeRateChanged(feeRate,feeRateMillion,feeRateBillion,feeRateHundredBillion,MIN_COIN_NUM);
    }
    event MinCoinNumChanged(uint256 minCoinNum,bool isAdd);
    function setMinCoinNum(uint256 minCoinNum,bool isAdd) public onlyOwner{
        if(minCoinNum > 0){
            MIN_COIN_NUM = minCoinNum;
            IS_ADD = isAdd;
            emit MinCoinNumChanged(MIN_COIN_NUM,isAdd);
        }
    }
}