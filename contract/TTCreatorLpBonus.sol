// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.9.3/interfaces/IERC20.sol";
import "@openzeppelin/contracts@4.9.3/access/Ownable.sol";

interface IAmount {
    function getTotalLpDividendAmount() external view returns (uint256);
    function getAmount(address account) external view returns(uint256, uint256);
}

contract TTCreatorLpBonus is Ownable {
    address public token;
    address public crowdFunding;
    mapping(address => uint256) private receivedAmounts;

    event GetReward(address sender, uint256 amount);

    function getReward() public {
        uint256 totalSupply = getTotalSupply();
        require(totalSupply > 0, "can not get reward now");
        (, uint256 rewardAmount, ) = getRewardAmount(msg.sender);
        require(rewardAmount > 0, "reward limit");
        IERC20(token).transfer(msg.sender, rewardAmount);
        receivedAmounts[msg.sender] += rewardAmount;
        
        emit GetReward(msg.sender, rewardAmount);
    }

    function getTotalSupply() public view returns(uint256) {
        return IAmount(token).getTotalLpDividendAmount();
    }

    function getRewardAmount(address account) public view returns (uint256, uint256, uint256) {
        uint256 totalSupply = getTotalSupply();
        if (totalSupply == 0) {
            return (0, 0, 0);
        }

        (uint256 crowdfundingAmount, uint256 total) = IAmount(crowdFunding).getAmount(account);
        if(crowdfundingAmount > 0) {
             uint256 totalAmount =  crowdfundingAmount * totalSupply / total;
             uint256 rewardAmount = totalAmount - receivedAmounts[account];
             return (totalAmount, rewardAmount, receivedAmounts[account]);
        } else {
            return (0, 0, 0);
        }
    }
    
    function withdraw(uint256 amount) public onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    function setAddress(address _token, address _crowdFunding) public onlyOwner {
        token = _token;
        crowdFunding = _crowdFunding;
    }
}

