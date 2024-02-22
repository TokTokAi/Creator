// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address public _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IUniswapV2Factory {

    function createPair(address tokenA, address tokenB) external returns (address pair);

}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

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
}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

contract Wallet {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function withdraw(address token) external {
        assert(msg.sender == owner);
        IERC20(token).transfer(
            msg.sender,
            IERC20(token).balanceOf(address(this))
        );
    }
}

contract TiTiCreatorToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name = "";
    string private _symbol = "";
    uint256 private _decimals = 18;
    
    uint256 public _liquidityFee = 2;
    uint256 private _previousLiquidityFee = 2;


    uint256 public _lpDividendFee = 4;
    uint256 private _previousLpDividendFee = 4;

    uint256 public _burnFee = 1;
    uint256 private _previousBurnFee = 1;

    uint256 public _creatorFee = 3; 
    uint256 private _previousCreatorFee = 3;

    uint256 public taxFee = 5;

    address public lpDividendAddress;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    address public creator;

    struct valueStruct {
        uint256 transferAmount;
        uint256 liquidity;
        uint256 creator;
        uint256 burn;
        uint256 lpDividend;
    }

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;
    uint256 public numTokensSellToAddToLiquidity;

    address private TT;
    Wallet private _wallet;
    string public icon;
    uint256 private totalLpDividendAmount;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor (string memory tokenName, string memory tokenSymbol, string memory _icon, address _TT, address routerAddress, address _creator, address _lpDividendAddress, address _tokenCrowdfundingAddress) public {
        _name = tokenName;
        _symbol = tokenSymbol;
        _tTotal = 1000000 * 10 ** _decimals;
        _rTotal = (MAX - (MAX % _tTotal));
        TT = _TT;
        creator = _creator;
        lpDividendAddress = _lpDividendAddress;
        icon = _icon;

        numTokensSellToAddToLiquidity = 5000 * 10 ** _decimals;

        _rOwned[_tokenCrowdfundingAddress] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), TT);

        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), routerAddress, MAX);
        IERC20(_TT).approve(routerAddress, MAX);  
        
        _isExcludedFromFee[_tokenCrowdfundingAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[lpDividendAddress] = true;
    
        _owner = msg.sender;
        _wallet = new Wallet();
        emit Transfer(address(0), _tokenCrowdfundingAddress, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,valueStruct memory rValues,) = _getValues(tAmount);
            return rValues.transferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) public onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function setWhiteList(address [] memory accounts, bool isWhite) public onlyOwner {
          for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = isWhite;
        }
    }

    function setNumTokensSellToAddToLiquidity(uint256 swapNumber) public onlyOwner {
        numTokensSellToAddToLiquidity = swapNumber * 10 ** _decimals;
    }
    
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function removeAllFee() private {
        _previousLiquidityFee = _liquidityFee;
        _previousLpDividendFee = _lpDividendFee;
        _previousBurnFee = _burnFee;
        _previousCreatorFee = _creatorFee;

        
        _liquidityFee = 0;
        _lpDividendFee = 0;
        _burnFee = 0;
        _creatorFee=0;
    }
    
    function restoreAllFee() private {
        _liquidityFee = _previousLiquidityFee;
        _lpDividendFee = _previousLpDividendFee;
        _burnFee = _previousBurnFee;
        _creatorFee = _previousCreatorFee;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance > 0 &&
            !inSwapAndLiquify &&
            to == uniswapV2Pair
        ) {
            swapAndLiquify(contractTokenBalance);
        }

        uint8 transactionType = 0;
      

        if (from == uniswapV2Pair || to == uniswapV2Pair) {
            transactionType = 1;
        }
        
        bool takeFee = true;
        
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || transactionType == 0) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee, transactionType);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
         if (contractTokenBalance >= numTokensSellToAddToLiquidity) {
            contractTokenBalance = numTokensSellToAddToLiquidity; 
            uint256 half = contractTokenBalance.div(2);
            uint256 otherHalf = contractTokenBalance.sub(half);

            uint256 initialBalance = IERC20(TT).balanceOf(address(this));
            swapTokensForTT(half); 
            uint256 newBalance = IERC20(TT).balanceOf(address(this)).sub(initialBalance);

            addLiquidity(otherHalf, newBalance);
            emit SwapAndLiquify(half, newBalance, otherHalf);
        }
    }

    function swapTokensForTT(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = TT;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(_wallet),
            block.timestamp
        );
        _wallet.withdraw(path[1]);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ttAmount) private {

        uniswapV2Router.addLiquidity(address(this), TT, tokenAmount, ttAmount, 0, 0, burnAddress, block.timestamp);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee, uint8 transactionType) private {
        if(!takeFee)
            removeAllFee();
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount, transactionType);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount, transactionType);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount, transactionType);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount, transactionType);
        } else {
            _transferStandard(sender, recipient, amount, transactionType);
        }
        
        if(!takeFee)
            restoreAllFee();
    }

    function _takeFeeAddress(address sender, address recipient, uint256 tAmount, uint256 currentRate) private {
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        
        if (tAmount > 0) {
            emit Transfer(sender, recipient, tAmount);
        }

        if(_isExcluded[recipient])
            _tOwned[recipient] = _tOwned[recipient].add(tAmount);
    }

    function _takeFee(address sender, valueStruct memory tValues, uint8 transactionType) private {
        uint256 currentRate =  _getRate();

        if(transactionType == 1) {
            _takeFeeAddress(sender, address(this), tValues.liquidity, currentRate);
            _takeFeeAddress(sender, burnAddress, tValues.burn, currentRate);
            _takeFeeAddress(sender, creator, tValues.creator, currentRate);

             uint256 balanceBefore = balanceOf(lpDividendAddress);
            _takeFeeAddress(sender, lpDividendAddress, tValues.lpDividend, currentRate);
             uint256 newH2Balance = balanceOf(lpDividendAddress).sub(balanceBefore);
             totalLpDividendAmount += newH2Balance;
        }
    }

     function _getValues(uint256 tAmount) private view returns (uint256, valueStruct memory, valueStruct memory) {
        valueStruct memory tValues = _getTValues(tAmount);
        (uint256 rAmount, valueStruct memory rValues) = _getRValues(tAmount, tValues, _getRate());
        return (rAmount, rValues, tValues);
    }

    function _getTValues(uint256 tAmount) private view returns (valueStruct memory) {
        valueStruct memory tValues;

        uint256 tax = tAmount.mul(taxFee).div(100);
        tValues.burn = tax.mul(_burnFee).div(10);
        tValues.creator = tax.mul(_creatorFee).div(10);
        tValues.liquidity = tax.mul(_liquidityFee).div(10);
        tValues.lpDividend = tax.mul(_lpDividendFee).div(10);
        tValues.transferAmount = tAmount.sub(tValues.burn).sub(tValues.creator).sub(tValues.liquidity).sub(tValues.lpDividend);
        return tValues;
    }

    function _getRValues(uint256 tAmount, valueStruct memory tValues, uint256 currentRate) private pure returns (uint256, valueStruct memory) {
        valueStruct memory rValues;
        uint256 rAmount = tAmount.mul(currentRate);

        rValues.burn = tValues.burn.mul(currentRate);
        rValues.creator = tValues.creator.mul(currentRate);
        rValues.liquidity = tValues.liquidity.mul(currentRate);
        rValues.lpDividend = tValues.lpDividend.mul(currentRate);
        rValues.transferAmount = rAmount.sub(rValues.burn).sub(rValues.creator).sub(rValues.liquidity).sub(rValues.lpDividend);
        
        return (rAmount, rValues);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, uint8 transactionType) private {
        (uint256 rAmount, valueStruct memory rValues, valueStruct memory tValues) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rValues.transferAmount);

        _takeFee(sender, tValues, transactionType);
        emit Transfer(sender, recipient, tValues.transferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount, uint8 transactionType) private {
        (uint256 rAmount, valueStruct memory rValues, valueStruct memory tValues) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tValues.transferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rValues.transferAmount);           
        
        _takeFee(sender, tValues, transactionType);
        emit Transfer(sender, recipient, tValues.transferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount, uint8 transactionType) private {
        (uint256 rAmount, valueStruct memory rValues, valueStruct memory tValues) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rValues.transferAmount);   
        
        _takeFee(sender, tValues, transactionType);
        emit Transfer(sender, recipient, tValues.transferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount, uint8 transactionType) private {
        (uint256 rAmount, valueStruct memory rValues, valueStruct memory tValues) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tValues.transferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rValues.transferAmount);        
        
        _takeFee(sender, tValues, transactionType);

        emit Transfer(sender, recipient, tValues.transferAmount);
    }

    function setAddress(address newLpDividend) public onlyOwner {
        lpDividendAddress = newLpDividend;
    }

    function setTax(uint256 _taxFee, uint256 liquidityFee, uint256 lpDividendFee, uint256 burnFee, uint256 creatorFee) public onlyOwner {
        taxFee = _taxFee;
        _liquidityFee = liquidityFee;
        _lpDividendFee = lpDividendFee;
        _burnFee = burnFee;
        _creatorFee = creatorFee;
        _previousLiquidityFee = liquidityFee;
        _previousLpDividendFee = lpDividendFee;
        _previousBurnFee = burnFee;
        _previousCreatorFee = creatorFee;
    }

    function getTotalLpDividendAmount() public view returns (uint256) {
        return totalLpDividendAmount;
    }
}