// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.9.3/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts@4.9.3/access/AccessControl.sol";
import "@openzeppelin/contracts@4.9.3/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts@4.9.3/utils/cryptography/EIP712.sol";

interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IPancakeRouter {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

contract TTCreatorCrowdfunding is AccessControl, EIP712 {
    address public pair;
    address public TT;
    address public router;
    address public token;
    uint256 public endTime;
    uint256 public claimStartTime;
    uint256 public createTime;
    uint256 public MAX = ~uint256(0);
    mapping(address => uint256) public crowdfundings;
    uint256 public totalAmount;
    uint256 public lpAmount;
    mapping(address => uint256) private claimedAmounts;

    mapping(address => bool) public hasCrowdfunding;
    mapping(address => uint256) public accountIndex;
    Record [] private records;

    bool public isAdd = false;
    bool public canClaim = false;
    uint256 public days_3 = 86400 * 3;
    uint256 public year_1 = 86400 * 365;
    address public constant burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public ttMax = 50000 * 1E18;
    address public signAddress;
    
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant _PERMIT_TYPEHASH = keccak256("Permit(address creator,uint256 deadline)");  
    mapping(bytes => bool) private hashList;
   
    event Crowdfunding(address sender, address TT, uint256 amount);
    event Claim(address sender, uint256 amount);
    event Withdraw(address sender, address TT, uint256 amount);

    struct Record {
        address account;
        uint256 amount;
    }

    constructor(address _TT, address _router, address _signAddress) EIP712('TTCreatorCrowdfunding', '1'){
        TT = _TT;
        router = _router;
        createTime = block.timestamp;
        endTime = createTime + days_3;
        signAddress = _signAddress;
        IERC20(TT).approve(router, MAX);
       
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, msg.sender);
    }

    function crowdfunding(uint256 amount, address sender, uint256 deadline, bytes memory signature) public {
        require(msg.sender == sender, "not owner");
        require(block.timestamp <= endTime, "can not crowdfunding now");
        require(amount > 0, "amount less than 0");
        require(amount + totalAmount <= ttMax, "crowdfunding quota is full");

        require(!hashList[signature], "hash is used");
        hashList[signature] = true;
        require(isSigner(sender, deadline, signature), "data is wrong");

        IERC20(TT).transferFrom(msg.sender, address(this), amount);
        crowdfundings[msg.sender] += amount;
        totalAmount += amount;
        
        if (hasCrowdfunding[msg.sender]) {
            uint256 index = accountIndex[msg.sender];
            records[index].amount += amount;
        } else {
            Record memory record;
            record.account = msg.sender;
            record.amount = amount;
            records.push(record);
            accountIndex[msg.sender] = records.length - 1;
            hasCrowdfunding[msg.sender] = true;
        }
    
        emit Crowdfunding(msg.sender, TT, amount);
    }

    function addLiquidity() public onlyRole(MANAGER_ROLE) {
        require(block.timestamp > endTime, "can not addLiquidity now");
        require(!isAdd, "has already addLiquidity");
        uint256 tokenAmount = IERC20(token).balanceOf(address(this));
        uint256 ttAmount = IERC20(TT).balanceOf(address(this));
        require(tokenAmount > 0 && ttAmount > 0, "no token");
        uint256 balanceBefore = IERC20(pair).balanceOf(address(this));
        IPancakeRouter(router).addLiquidity(token, TT, tokenAmount, ttAmount, 0, 0, address(this), block.timestamp);
        lpAmount = IERC20(pair).balanceOf(address(this)) - balanceBefore;
        isAdd = true;
        claimStartTime = block.timestamp;
    }

    function claim() public {
        require(crowdfundings[msg.sender] > 0, "no crowdfunding");
        require(lpAmount > 0, "no liquidity");
        require(block.timestamp > claimStartTime + year_1 || canClaim, "can not claim now");
        uint256 amount = crowdfundings[msg.sender] * lpAmount / totalAmount;

        uint256 tokenBalanceBefore = IERC20(token).balanceOf(address(this));
        uint256 TTBalanceBefore = IERC20(TT).balanceOf(address(this));

        IPancakeRouter(router).removeLiquidity(token, TT, amount, 0, 0, address(this), block.timestamp + 60);

        uint256 tokenBurnAmount = IERC20(token).balanceOf(address(this)) - tokenBalanceBefore;
        IERC20(token).transfer(burnAddress, tokenBurnAmount);

        uint256 TTBalanceAmount = IERC20(TT).balanceOf(address(this)) - TTBalanceBefore;
        if (TTBalanceAmount > crowdfundings[msg.sender]) {
            IERC20(TT).transfer(burnAddress, TTBalanceAmount - crowdfundings[msg.sender]);
            IERC20(TT).transfer(msg.sender, crowdfundings[msg.sender]);
        } else {
            IERC20(TT).transfer(msg.sender, TTBalanceAmount);
        }
        crowdfundings[msg.sender] = 0;

        emit Claim(msg.sender, amount);
    }

    function isSigner(address creator, uint256 deadline, bytes memory signature) public view returns (bool) {
        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, creator, deadline));

        bytes32 hash = _hashTypedDataV4(structHash);
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
        address signer = ECDSA.recover(hash, v, r, s);
        return signer == signAddress;
    }

    function setSigner(address _signAddress) public onlyRole(MANAGER_ROLE) {
        signAddress = _signAddress;
    }

    function withdrawTT() public {
        require(!isAdd, "can not withdraw now");
        uint256 amount = crowdfundings[msg.sender];
        require(amount > 0, "no crowdfunding");
        IERC20(TT).transfer(msg.sender, amount);
        crowdfundings[msg.sender] = 0;
        totalAmount -= amount;
        uint256 index = accountIndex[msg.sender];
        records[index].amount = 0;

        emit Withdraw(msg.sender, TT, amount);
    }

    function setCanClaim(bool _canClaim) public onlyRole(MANAGER_ROLE) {
        canClaim = _canClaim;
    }

    function getPoolBalance() public view returns (uint256, uint256) {
        uint256 tokenBalance = IERC20(token).balanceOf(address(this));
        uint256 TTBalance = IERC20(TT).balanceOf(address(this));
        return (tokenBalance, TTBalance);
    }

    function getRecordsLength() public view returns(uint256) {
        return records.length;
    }

    function getRecords() public view returns(Record [] memory) {
        return records;
    } 

    function getRecordByIndex(uint256 index) public view returns(Record memory) {
        return records[index];
    } 

    function getAmount(address account) public view returns(uint256, uint256) {
        return (crowdfundings[account], totalAmount);
    }

    function setTTMAX(uint256 _ttMax) public onlyRole(MANAGER_ROLE) {
        ttMax = _ttMax;
    }

    function setAddress(address _token) public onlyRole(MANAGER_ROLE) {
        token = _token;
        IERC20(token).approve(router, MAX);
        pair = ISwapFactory(IPancakeRouter(router).factory()).getPair(token, TT);
        IERC20(pair).approve(router, MAX);
    }

    function setEndTime(uint256 _endTime) public onlyRole(MANAGER_ROLE) {
        endTime = _endTime;
    }

    function withdrawLP(uint256 amount) public onlyRole(MANAGER_ROLE) {
        IERC20(pair).transfer(msg.sender, amount);
    }
}
