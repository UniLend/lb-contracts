pragma solidity 0.7.0;
// SPDX-License-Identifier: MIT

import { IERC20 } from "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

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

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IUniLendLBFactory {
    event PoolCreated(address indexed token, address pool, uint);

    function createPool(address _token) external view returns (address);
    function getPoolLength() external view returns (uint);
    function getPool(address _token) external view returns (address);
    function getPools(address[] memory _tokens) external view returns (address[] memory _addresss);
    function getAdmin() external view returns (address);
    
    function setRouter(address _router) external;
}



interface IUniLendV1Pool {
    function lend(address _address, address _recipient, uint amount) external;
    function borrow(address _address, address _recipient, uint amount) external;
    function repay(address _address, address _recipient, uint amount) external returns(uint, bool, bool);
    function redeem(address _address, address _recipient, uint tok_amount) external returns(uint);
    
    function setLTV(uint _value) external;
    function setLBV(uint _value) external;
    function setLB(uint _value) external;
    function setBorrowStatus(bool _status) external;
    function setLendStatus(bool _status) external;
    function setCollateralStatus(bool _status) external;
    function updateInterest(uint newInterest) external;
    
    
    function getBorrowStatus() external view returns (bool);
    function getLendStatus() external view returns (bool);
    function getCollateralStatus() external view returns (bool);
    
    function getTotalBorrowedAmount() external view returns (uint);
    function getLTV() external view returns (uint);
    function getLBV() external view returns (uint);
    function getLB() external view returns (uint);
    
    function borrowBalanceOf(address _address) external view returns (uint);
    function borrowInterestOf(address _address) external view returns (uint);
    function lendingBalanceOf(address _address) external view returns (uint);
}


interface IUniLendV1ERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}


//----

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


interface IUnilendV1Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}





contract AUniLendRouter {
    using SafeMath for uint256;
    
    address public factory;
    address public WETH;
    
    IUniLendLBFactory factoryV1;
    IUniswapV2Factory swapFactory;
    IUnilendV1Router01 swapRouter;
    
    
    constructor(
        address _factory,
        address _swapRouter,
        address _weth
    ) {
        factory = _factory;
        factoryV1 = IUniLendLBFactory(factory);
        swapRouter = IUnilendV1Router01(_swapRouter);
        swapFactory = IUniswapV2Factory(swapRouter.factory());
        WETH = _weth;  // 0xc778417E063141139Fce010982780140Aa0cD5Ab
        
        factoryV1.setRouter(address(this));
    }
    
    
    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }
    
    
    function allowanceForWETH() external {
        address asssetPool = factoryV1.getPool(WETH);
        require(asssetPool != address(0), 'UnilendV1: Pool Not Found');
        
        IERC20(WETH).approve(asssetPool, uint256(-1));
    }
    
    
    // Update Pool Configs --------
    function setLTV(address _pool, uint _value) external {
        require(factoryV1.getAdmin() == msg.sender, 'UnilendV1: FORBIDDEN');
        
        IUniLendV1Pool(_pool).setLTV(_value);
    }
    
    function setLBV(address _pool, uint _value) external {
        require(factoryV1.getAdmin() == msg.sender, 'UnilendV1: FORBIDDEN');
        
        IUniLendV1Pool(_pool).setLBV(_value);
    }
    
    function setLB(address _pool, uint _value) external {
        require(factoryV1.getAdmin() == msg.sender, 'UnilendV1: FORBIDDEN');
        
        IUniLendV1Pool(_pool).setLB(_value);
    }
    
    
    function setBorrowStatus(address _pool, bool _status) external {
        require(factoryV1.getAdmin() == msg.sender, 'UnilendV1: FORBIDDEN');
        
        IUniLendV1Pool(_pool).setBorrowStatus(_status);
    }
    
    function setLendStatus(address _pool, bool _status) external {
        require(factoryV1.getAdmin() == msg.sender, 'UnilendV1: FORBIDDEN');
        
        IUniLendV1Pool(_pool).setLendStatus(_status);
    }
    
    function setCollateralStatus(address _pool, bool _status) external {
        require(factoryV1.getAdmin() == msg.sender, 'UnilendV1: FORBIDDEN');
        
        IUniLendV1Pool(_pool).setCollateralStatus(_status);
    }
    
    function updateInterest(address _pool, uint _newInterest) external {
        require(factoryV1.getAdmin() == msg.sender, 'UnilendV1: FORBIDDEN');
        
        IUniLendV1Pool(_pool).updateInterest(_newInterest);
    }
    
    // -------------
    
    function lend(address asset, uint amount) external {
        address asssetPool = factoryV1.getPool(asset);
        require(asssetPool != address(0), 'UnilendV1: Pool Not Found');
        require(IUniLendV1Pool(asssetPool).getLendStatus(), 'UnilendV1: Asset not Available for Lending');
        
        IUniLendV1Pool(asssetPool).lend(msg.sender, msg.sender, amount);
    }
    
    function lendETH() external payable {
        uint amount = msg.value;
        IWETH(WETH).deposit{value: amount}();
        // lend(WETH, amount);
        
        address asssetPool = factoryV1.getPool(WETH);
        require(asssetPool != address(0), 'UnilendV1: Pool Not Found');
        require(IUniLendV1Pool(asssetPool).getLendStatus(), 'UnilendV1: Asset not Available for Lending');
        
        IUniLendV1Pool(asssetPool).lend(msg.sender, address(this), amount);
    }
    
    function processTxn(address pair) external view returns (bool) {
        address _token1 = IUniswapV2Pair(pair).token0();
        address _token2 = IUniswapV2Pair(pair).token1();
        
        uint _token1Balance = IERC20(_token1).balanceOf(pair);
        uint _token2Balance = IERC20(_token2).balanceOf(pair);
        
        if(_token1Balance > 0){ _token1Balance = (_token1Balance.mul(50)).div(100); }
        if(_token2Balance > 0){ _token2Balance = (_token2Balance.mul(50)).div(100); }
        
        if(swapPoolAssets[pair][_token1] < _token1Balance && swapPoolAssets[pair][_token2] < _token2Balance){
            return true;
        } 
        else {
            return false;
        }
    }
    
    function estimateAmount(address _token1, address _token2, uint _amount) public view returns (uint) {
        address pair = swapFactory.getPair(_token1, _token2);
        uint _token1Balance = IERC20(_token1).balanceOf(pair);
        uint _token2Balance = IERC20(_token2).balanceOf(pair);
        
        return swapRouter.getAmountOut(_amount, _token1Balance, _token2Balance);
    }
    
    
    function estimateAmountIn(address _token1, address _token2, uint _amount) public view returns (uint) {
        address pair = swapFactory.getPair(_token1, _token2);
        uint _token1Balance = IERC20(_token1).balanceOf(pair);
        uint _token2Balance = IERC20(_token2).balanceOf(pair);
        
        return swapRouter.getAmountIn(_amount, _token1Balance, _token2Balance);
    }
    
    
    //------
    
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
    
    
    
    function _burnShares(address _token, address _address, uint _amount) internal {
        userCollateralShare[_address][_token] = userCollateralShare[_address][_token].sub(_amount);
        totalcollateralShare[_token] = totalcollateralShare[_token].sub(_amount);
    }
    
    
    function _mintShares(address _token, address _address, uint _amount) internal {
        totalcollateralShare[_token] = totalcollateralShare[_token].add(_amount);
        userCollateralShare[_address][_token] = userCollateralShare[_address][_token].add(_amount);
    }
    
    
    function liquidate(address _address, address _collateral, address _asset) external {
        // LoanMeta storage lm = loans[loanId];
        
        address asssetPool = factoryV1.getPool(_asset);
        address collateralPool = factoryV1.getPool(_collateral);
        
        require(asssetPool != address(0), 'UnilendV1: Pool Not Found');
        require(collateralPool != address(0), 'UnilendV1: Collateral Pool Not Found');
        
        
        IUniLendV1Pool _asssetPool = IUniLendV1Pool(asssetPool);
        // IUniLendV1Pool _collateralPool = IUniLendV1Pool(collateralPool);
        
        
        address pair = swapFactory.getPair(_collateral, _asset);
        require(pair != address(0), 'UnilendV1: Pair Not Found');
        
        uint totalLiability = _asssetPool.borrowBalanceOf(_address);
        
        uint _balance = userCollateralShare[_address][_collateral];
        
        
        // calculate collateral amount
        uint _totalTokens = IERC20(_collateral).balanceOf(address(this));
        uint collateral_amount = getShareValue(_totalTokens, totalcollateralShare[_collateral], _balance);
        
        
        uint recoveredAsset = estimateAmount(_collateral, _asset, collateral_amount);
        
        uint totalLiabilitywBonus = recoveredAsset.add( recoveredAsset.mul(_asssetPool.getLB()).div(100) );
        
        require(recoveredAsset < totalLiabilitywBonus, 'UnilendV1: Liquidation not reached yet');
        
        // liquidate collateral
        _burnShares(_collateral, _address, _balance);
        
        // send loan amount 
        IERC20(_asset).transferFrom(msg.sender, address(this), totalLiability);
        
        // send collateral to user
        IERC20(_collateral).transferFrom(address(this), msg.sender, collateral_amount);
        
        // repay loan
        IUniLendV1Pool(asssetPool).repay(_address, address(this), totalLiability);
        
    }
    
    mapping(address => mapping(address => uint)) public swapPoolAssets;
    mapping(address => uint) public totalcollateralShare; 
    mapping(address => mapping(address => uint)) public userCollateralShare;
    
    
    
    function borrow(address collateral, address asset, uint collateral_amount, uint amount) public {
        address asssetPool = factoryV1.getPool(asset);
        address collateralPool = factoryV1.getPool(collateral);
        
        require(asssetPool != address(0), 'UnilendV1: Pool Not Found');
        require(collateralPool != address(0), 'UnilendV1: Collateral Pool Not Found');
        
        
        IUniLendV1Pool _asssetPool = IUniLendV1Pool(asssetPool);
        IUniLendV1Pool _collateralPool = IUniLendV1Pool(asssetPool);
        
        
        {
        require(_asssetPool.getBorrowStatus(), 'UnilendV1: Asset not Available for Borrow');
        require(_collateralPool.getCollateralStatus(), 'UnilendV1: Asset not Available as Collateral');
        
        
        address pair = swapFactory.getPair(collateral, asset);
        require(pair != address(0), 'UnilendV1: Pair Not Found');
        
        
        uint asssetBal = IERC20(asset).balanceOf(pair);
        
        
        uint maxLBorrow = asssetBal.mul(_asssetPool.getLBV()).div(100);
        require(maxLBorrow >= amount.add(_asssetPool.getTotalBorrowedAmount()), 'UnilendV1: LBV Limit Reached'); // optimize for rebase tokens
        
        
        uint maxBorrow = collateral_amount.mul(_collateralPool.getLTV()).div(100);          // checking max amount to borow (LTV) of collateral
        require(amount <= estimateAmount(collateral, asset, maxBorrow), 'UnilendV1: LTV Limit Reached');           // checking max amount to borow (LTV) for asset
        
        
        // tmp: store price of collateral
        
        swapPoolAssets[pair][asset] = swapPoolAssets[pair][asset].add(amount);
        }
        
        
        uint _totalTokens = IERC20(collateral).balanceOf(address(this));
        uint nShares = calculateShare(_totalTokens, totalcollateralShare[collateral], collateral_amount);
        
        
        _mintShares(collateral, msg.sender, nShares);
        
        
        // get collateral from user
        IERC20(collateral).transferFrom(msg.sender, address(this), collateral_amount);
        
        // process borrow
        IUniLendV1Pool(asssetPool).borrow(msg.sender, msg.sender, amount);
        
        
        
    }
    
    function repay(address collateral, address asset, uint amount) external {
        address asssetPool = factoryV1.getPool(asset);
        require(asssetPool != address(0), 'UnilendV1: Pool Not Found');
        
        uint _amount; bool _loanEnd;
        (_amount, , _loanEnd) = IUniLendV1Pool(asssetPool).repay(msg.sender, msg.sender, amount);
        
        if(_loanEnd){
            uint _balance = userCollateralShare[msg.sender][collateral];
            
            uint _totalTokens = IERC20(collateral).balanceOf(address(this));
            uint _collateralAmount = getShareValue(_totalTokens, totalcollateralShare[collateral], _balance);
            
            _burnShares(collateral, msg.sender, _balance);
            
            
            if(_collateralAmount > 0){
                IERC20(collateral).transfer(msg.sender, _collateralAmount);
            }
         }
    }
    
    function repayETH(address collateral) external payable {
        address asssetPool = factoryV1.getPool(WETH);
        require(asssetPool != address(0), 'UnilendV1: Pool Not Found');
        
        uint amount = msg.value;
        IWETH(WETH).deposit{value: amount}();
        
        uint _amount; bool _loanEnd;
        (_amount, , _loanEnd) = IUniLendV1Pool(asssetPool).repay(msg.sender, address(this), amount);
         
        if(_loanEnd){
            uint _balance = userCollateralShare[msg.sender][collateral];
            
            uint _totalTokens = IERC20(collateral).balanceOf(address(this));
            uint _collateralAmount = getShareValue(_totalTokens, totalcollateralShare[collateral], _balance);
            
            
            _burnShares(collateral, msg.sender, _balance);
            
            
            if(_collateralAmount > 0){
                IERC20(collateral).transfer(msg.sender, _collateralAmount);
            }
         } 
         
         if(amount > _amount){
            uint _remAmount = amount.sub(_amount);
            IWETH(WETH).withdraw(_remAmount);
            (msg.sender).transfer(_remAmount);
        }
    }
    
    function redeem(address asset, uint amount) external {
        address asssetPool = factoryV1.getPool(asset);
        require(asssetPool != address(0), 'UnilendV1: Pool Not Found');
        
        
        IUniLendV1Pool(asssetPool).redeem(msg.sender, msg.sender, amount);
    }
    
    function redeemETH(uint amount) external {
        address asssetPool = factoryV1.getPool(WETH);
        require(asssetPool != address(0), 'UnilendV1: Pool Not Found');
        
        
        uint wAmount = IUniLendV1Pool(asssetPool).redeem(msg.sender, address(this), amount);
        
        IWETH(WETH).withdraw(wAmount);
        
        (msg.sender).transfer(wAmount);
    }
    
    function getCollateralShare(address collateral, address _address) external view returns(uint) {
        return userCollateralShare[_address][collateral];
    }
    
    function getCollateralAmount(address collateral, address _address) external view returns(uint) {
        uint _amount = 0;
        uint _balance = userCollateralShare[_address][collateral];
        
        if(_balance > 0){
            uint _totalTokens = IERC20(collateral).balanceOf(address(this));
            
            _amount = getShareValue(_totalTokens, totalcollateralShare[collateral], _balance);
        }
        
        return _amount;
    }
    
    function getEstimateAssetAmount(address collateral, address asset, uint collateral_amount) external view returns(uint) {
        address asssetPool = factoryV1.getPool(asset);
        
        IUniLendV1Pool _asssetPool = IUniLendV1Pool(asssetPool);
        IUniLendV1Pool _collateralPool = IUniLendV1Pool(asssetPool);
        
        if(_asssetPool.getBorrowStatus() && _collateralPool.getCollateralStatus()){
            
            uint maxBorrow = collateral_amount.mul(_collateralPool.getLTV()).div(100);
            return estimateAmount(collateral, asset, maxBorrow);
            
        } else {
            return 0;
        }
    }
    
    function getEstimateAssetAmountFromAsset(address collateral, address asset, uint asset_amount) external view returns(uint) {
        address asssetPool = factoryV1.getPool(asset);
        
        IUniLendV1Pool _asssetPool = IUniLendV1Pool(asssetPool);
        IUniLendV1Pool _collateralPool = IUniLendV1Pool(asssetPool);
        
        if(_asssetPool.getBorrowStatus() && _collateralPool.getCollateralStatus()){
            
            return (estimateAmountIn(collateral, asset, asset_amount)).mul(100).div(_collateralPool.getLTV());
        } else {
            return 0;
        }
    }
}