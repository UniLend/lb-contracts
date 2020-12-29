pragma solidity 0.7.0;
// SPDX-License-Identifier: MIT

import { ERC20 } from "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


//----

contract UPool is ERC20 {
    
    using SafeMath for uint256;
    
    address public factory;
    address public router;
    
    
    modifier onlyRouter() {
        require(msg.sender == router, 'UnilendV1: UnAutorised Operaton');
        _;
    }
    
    
    constructor(
        address _router,
        address _token,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        factory = msg.sender;
        router = _router;
        token = _token;
        
        ltv = 70;
        lbv = 50;
        lb = 10;
        
        // liquidationBonus = 5;
        
        borrowStatus = true;
        lendStatus = true;
        collateralStatus = true;
        
        _updateInterest(200000); // 20%
    }
    
    
    address public token;
    
    
    uint256 public tborrowAmount;
    uint256 public tsupplyAmount;
    // uint256 public tsupplyAvailable;
    
    
    uint public blockinterestRate;
    // uint public liquidationBonus;
    
    
    
    uint public lastInterestBlock;
    
    uint public totalinterest;
    uint public totalPaidinterest;
    
    
    
    uint ltv;  // loan to value
    uint lbv;  // liquidity borrow value
    uint lb;   // liquidation bonus
    
    bool borrowStatus;
    bool lendStatus;
    bool collateralStatus;
    
    
    // mapping(address => supplyMeta) lendingData;
    mapping(address => mapping(uint => borrowMeta)) borrowData;
    mapping(address => uint) public borrowID;
    
    
    struct borrowMeta {
        uint amount;
        uint paid;
        uint paidInterest;
        uint interestShare;
        uint interestAmount;
        uint currentInterest;
        uint block;
        uint collateralAmount;
        bool status;
        address collateral;
    }
    
    
    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'UnilendV1: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
    
    
    function getTotalBorrowedAmount() external view returns (uint) {
        return tborrowAmount;
    }
    
    
    function getLTV() external view returns (uint) {
        return ltv;
    }
    
    
    
    function getLBV() external view returns (uint) {
        return lbv;
    }
    
    
    function getLB() external view returns (uint) {
        return lb;
    }
    
    
    function getBorrowStatus() external view returns (bool) {
        return borrowStatus;
    }
    
    
    function getLendStatus() external view returns (bool) {
        return lendStatus;
    }
    
    function getCollateralStatus() external view returns (bool) {
        return collateralStatus;
    }
    
    
    
    
    function setLTV(uint _value) external onlyRouter {
        ltv = _value;
    }
    
    
    function setLBV(uint _value) external onlyRouter {
        lbv = _value;
    }
    
    function setLB(uint _value) external onlyRouter {
        lb = _value;
    }
    
    
    function setBorrowStatus(bool _status) external onlyRouter {
        borrowStatus = _status;
    }
    
    
    function setLendStatus(bool _status) external onlyRouter {
        lendStatus = _status;
    }
    
    function setCollateralStatus(bool _status) external onlyRouter {
        collateralStatus = _status;
    }
    
    
    function _updateInterest(uint newInterest) internal {
        blockinterestRate = (newInterest*10**8).div(4*60*24*365);
    }
    
    
    function updateInterest(uint newInterest) public onlyRouter {
        _updateInterest(newInterest);
    }
    
    
    
    // -------------
    
    
    
    
    function _updateTotinterest() internal {
        uint remainingBlocks = block.number - lastInterestBlock;
        // totalinterest = totalinterest.add( ( tborrowAmount.mul( remainingBlocks.mul(blockinterestRate) )).div(10**12) );
        
        uint newAmount = ( tborrowAmount.mul( remainingBlocks.mul(blockinterestRate) )).div(10**12);
        
        tborrowAmount = tborrowAmount.add( newAmount );
        tsupplyAmount = tsupplyAmount.add( newAmount );
        
        lastInterestBlock = block.number;
    }
    
    
    function calculateShare(uint _totalShares, uint _totalAmount, uint _amount) public pure returns (uint){
        if(_totalShares == 0){
            return Math.sqrt(_amount.mul( _amount )).sub(1000);
        } else {
            return (_amount).mul( _totalShares ).div( _totalAmount );
        }
    }
    
    function getShareValue(uint _totalAmount, uint _totalSupply, uint _amount) public pure returns (uint){
        return ( _amount.mul(_totalAmount) ).div( _totalSupply );
    }
    
    function getShareByValue(uint _totalAmount, uint _totalSupply, uint _valueAmount) public pure returns (uint){
        return ( _valueAmount.mul(_totalSupply) ).div( _totalAmount );
    }
    
    function lend(address _address, address _recipient, uint amount) public onlyRouter {
        _updateTotinterest();
        
        uint _totalSupply = totalSupply();
        
        // uint _totalPoolAmount = tsupplyAmount.add(totalinterest);
        uint ntokens = calculateShare(_totalSupply, tsupplyAmount, amount);
        
        // transfer ERC20 token for amount
        IERC20(token).transferFrom(_recipient, address(this), amount);
        
        // mint uTokens
        _mint(_address, ntokens);
        
        tsupplyAmount = tsupplyAmount.add(amount);
    }
    
    
    uint public totalBorrowShare;
    mapping(address => uint) public borrowShare;
    
    
    function borrow(address _address, address _recipient, uint amount) public onlyRouter {
        _updateTotinterest();
        
        require(amount <= IERC20(token).balanceOf(address(this)), "Liquidity not available");
        require(amount > 0, "Borrow Amount Should be Greater than 0");
        
        
        
        uint nShares = calculateShare(tborrowAmount, totalBorrowShare, amount);
        borrowShare[_address] = borrowShare[_address].add(nShares);
        
        totalBorrowShare = totalBorrowShare.add(nShares);
        
        
        // transfer ERC20 token for amount
        IERC20(token).transfer(_recipient, amount);
        
        
        tborrowAmount = tborrowAmount.add(amount);
        // tsupplyAvailable = tsupplyAvailable.sub(amount);
    }
    
    
    function repay(address _address, address _recipient, uint amount) public onlyRouter returns(uint, bool, bool) {
        _updateTotinterest();
        
        uint borrowAmount = getShareValue(tborrowAmount, totalBorrowShare, borrowShare[_address]);
        
        if(amount > borrowAmount){
            amount = borrowAmount;
        }
        
        if(amount > 0){
            
            uint paidShare = getShareByValue(tborrowAmount, totalBorrowShare, amount);
            
            totalBorrowShare = totalBorrowShare.sub(paidShare);
            borrowShare[_address] = borrowShare[_address].sub(paidShare);
            
            tborrowAmount = tborrowAmount.sub(amount);
            
            // transfer ERC20 token for amount
            IERC20(token).transferFrom(_recipient, address(this), amount);
            
            if(amount == borrowAmount){
                // bm.status = false;
                // borrowID[_address] ++;
                borrowShare[_address] = 0;
                
                return (amount, true, true);
            } else {
                return (amount, true, false);
            }
            
        } 
        else {
            return (0, true, false);
        }
    }
    
    
    function borrowBalanceOf(address _address) public view returns (uint) {
        // borrowMeta storage bm = borrowData[_address][borrowID[_address]];
        
        uint _balance = borrowShare[_address];
        
        if(_balance > 0){
            
            uint _tsupplyAmount = tsupplyAmount;
            uint _tborrowAmount = tborrowAmount;
            
            if(lastInterestBlock < block.number){
                uint remainingBlocks = block.number - lastInterestBlock;
                
                uint newAmount = ( tborrowAmount.mul( remainingBlocks.mul(blockinterestRate) )).div(10**12);
                
                _tborrowAmount = tborrowAmount.add( newAmount );
                _tsupplyAmount = _tsupplyAmount.add( newAmount );
            }
            
            
            uint _totalPoolAmount = _tborrowAmount;
            return getShareValue(_totalPoolAmount, totalBorrowShare, _balance);
        } 
        else {
            return 0;
        }
    }
    
    
    function redeem(address _address, address _recipient, uint tok_amount) public onlyRouter returns(uint) {
        _updateTotinterest();
        
        require(balanceOf(_address) >= tok_amount, "Balance Exeeds Requested");
        
        uint poolAmount = getShareValue(tsupplyAmount, totalSupply(), tok_amount);
        
        require(IERC20(token).balanceOf(address(this)) >= poolAmount, "Not enough Liquidity");
        
        
        // tsupplyAvailable = tsupplyAvailable.sub(poolAmount);
        tsupplyAmount = tsupplyAmount.sub(poolAmount);
        
        
        // BURN uTokens
        _burn(_address, tok_amount);
        
        // transfer ERC20 token for amount
        IERC20(token).transfer(_recipient, poolAmount);
        
        return poolAmount;
    }
    
    
    function lendingBalanceOf(address _address) public view returns (uint) {
        uint _balance = balanceOf(_address);
        
        if(_balance > 0){
            uint _tsupplyAmount = tsupplyAmount;
            
            if(lastInterestBlock < block.number){
                uint remainingBlocks = block.number - lastInterestBlock;
                _tsupplyAmount = _tsupplyAmount.add( ( tborrowAmount.mul( remainingBlocks.mul(blockinterestRate) )).div(10**12) );
            }
            
            
            uint _totalPoolAmount = _tsupplyAmount;
            return getShareValue(_totalPoolAmount, totalSupply(), _balance);
        } 
        else {
            return 0;
        }
    }
}

contract AUniLendFactory is Context {
    using SafeMath for uint256;
    
    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'UnilendV1: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
    
    event PoolCreated(address indexed token, address pool, uint);
    
    address public router;
    address public admin;
    
    mapping(address => address) public Pools;
    mapping(address => address) public Assets;
    uint public poolLength;
    
    constructor()  {
        admin = msg.sender;
    }
    
    function createPool(address _token) public returns (address) {
        require(Pools[_token] == address(0), 'UnilendV1: POOL ALREADY CREATED');
        require(router != address(0), 'UnilendV1: ROUTER NOT CREATED YET');
        
        ERC20 asset = ERC20(_token);
        
        string memory aTokenName = string(abi.encodePacked("UnilendV1 - ", asset.name()));
        string memory aTokenSymbol = string(abi.encodePacked("u", asset.symbol()));
        
        
        UPool _poolMeta = new UPool(router, _token, aTokenName, aTokenSymbol);
        
        address _poolAddress = address(_poolMeta);
        
        Pools[_token] = _poolAddress;
        Assets[_poolAddress] = _token;
        
        poolLength++;
        
        emit PoolCreated(_token, _poolAddress, poolLength);
        
        return _poolAddress;
    }
    
    function setAdmin(address _admin) external {
        require(_admin == _admin, 'UnilendV1: FORBIDDEN');
        admin = _admin;
    }
    
    function getAdmin() external view returns (address) {
        return admin;
    }
    
    function getPoolLength() external view returns (uint) {
        return poolLength;
    }
    
    function getPool(address _token) external view returns (address) {
        return Pools[_token];
    }
    
    function getPools(address[] memory _tokens) external view returns (address[] memory) {
        address[] memory _addresss = new address[](_tokens.length);
        
        for (uint i=0; i<_tokens.length; i++) {
            _addresss[i] = Pools[_tokens[i]];
        }
        
        return _addresss;
    }
    
    function setRouter(address _router) external {
        require(router == address(0), 'UnilendV1: ROUTER ALREADY SET');
        router = _router;
    }
}