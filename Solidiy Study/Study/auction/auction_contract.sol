//SPDX-License-Identifier: MIT
//作者：叶力涛
pragma solidity ^0.8.0;
import "./mintNft.sol";

//拍卖合约
contract OpenAuction is MintNFT {
    // 最终受益者
    address payable public beneficiary;
    // 存储所有出价者的地址
    address[] public bidders;
    //拍卖结束时间
    uint256 public auctionEndTime;
    //拍卖合约部署者地址
    address public deployer;
    //拍卖起拍价
    uint256 bottomPrice;
    //最高出价者地址
    address public highestBidder;
    // 当前最高的出价
    uint256 public highestBid;
    //map,存储需要退回竞拍款的竞拍者和其出价
    mapping(address => uint256) public pendingReturns;
    //拍卖结束标识符
    bool public ended;
    // 出现更高出价时引发的事件
    event HighestBidIncreased(address bidder, uint256 amount);
    // 竞拍结束时引发的事件
    event AuctionEnded(address winner, uint256 amount);
    // 用户竞拍金额被超过，用户可以退回竞拍金额，调用这个函数引发的事件
    event BidWithdrawn(address bidder, uint256 amount);
    //拍卖开始引发的事件
    event AuctionStarted(uint256 tokenId, uint256 endTime);
    //给拍卖平台管理者分发奖励引发的事件
    event DistributeReward(address deployer, uint256 reward);

    /**
   初始化竞拍合约，指定竞拍期受益者，拍卖结束标识符初始化为true
    */
    constructor() MintNFT("YLTcoin", "YLTCN") {
        deployer = msg.sender;
        ended = true;
    }

    /**
    拍卖开始函数
    */
    function startAuction(
        uint256 _biddingTime,
        uint256 _tokenid,
        address payable _beneficiary,
        uint256 _bottomPrice
    ) public {
        // 检查调用者是否为该NFT的所有者
        require(
            msg.sender == ownerOf(_tokenid),
            "Only the owner of the NFT can start the auction"
        );
        // 如果NFT拥有者不是合约部署者，授权该合约部署者为该NFT的代理
        if (msg.sender != address(deployer)) {
            approve(address(deployer), _tokenid);
        }
        //要求tokenid>0
        require(_tokenid != 0, "Token ID should be greater than 0");
        //要求拍卖结束标识符为true
        require(
            ended,
            "There are still auctions not over, please wait for the last auction to end."
        );
        // require(_bottomPrice>=100,"The starting price must be greater than or equal to 100wei");
        //要求设置的拍卖时长大于0s
        require(_biddingTime > 0, "Bidding time should be greater than 0");
        //赋值tokenid
        tokenId = _tokenid;
        //设置本次拍卖收益者
        beneficiary = _beneficiary;
        //赋值起拍价
        bottomPrice = _bottomPrice;
        //根据设定的拍卖时长计算拍卖截止时间
        auctionEndTime = block.timestamp + _biddingTime;
        //拍卖结束标识符设为false
        ended = false;
        //初始化最高出价者地址为0地址
        highestBidder = address(0);
        //初始化最高出价金额为0
        highestBid = 0;
        // 触发拍卖开始事件
        emit AuctionStarted(_tokenid, auctionEndTime);
    }

    /**
    拍卖合约，用户调用该函数参与拍卖
    */
    function bid() public payable {
        //要求当前时间<拍卖截至时间
        require(block.timestamp <= auctionEndTime, "Auction already ended.");
        //拍卖出价要求大于0
        require(msg.value > 0, "Your bid should be greater than 0");
        //出价要大于起拍价
        require(
            msg.value > bottomPrice,
            "Your bid must be greater than the starting bid"
        );
        //要求出价金额大于当前最高出价者出价金额
        require(msg.value > highestBid, "There already is a higher bid.");
        //出价者不是当前最高出价者
        require(
            msg.sender != highestBidder,
            "You are already the highest bidder"
        );
        //要求该拍卖合约部署者不能参与拍卖
        require(
            msg.sender != deployer,
            "Auction contract deployers cannot participate in the auction"
        );
        //将该出价者和出价金额保存在数组里
        pendingReturns[highestBidder] += highestBid;
        // 将出价者地址添加到数组中
        bidders.push(msg.sender);

        // 用本次的出价 msg.value 和出价者 msg.sender 更新当前的最高出价金额 highestBid 和出价者地址 highestBidder
        highestBidder = msg.sender;
        highestBid = msg.value;

        // 触发本次竞拍价格变高的事件
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    /**
    查询拍卖剩余时间函数
    */
    function remainingTime() public view returns (uint256 time) {
        //判断当前查询时间是否还在拍卖时间内
        if (auctionEndTime > block.timestamp) {
            //返回拍卖剩余时间auctionEndTime - block.timestamp
            return auctionEndTime - block.timestamp;
        } else {
            //查询时拍卖未开始或者拍卖已结束，返回0
            return 0;
        }
    }

    /**
    撤回出价函数，用户如果出价被别人超过，已经不是出价最高者，可以调用这个函数撤回出价。
    调用该函数的用户如果是最高出价者，可以撤回之前的出价，不能撤回出的最高价（即不能反悔，不想成为出价最高者）
    */
    function withdraw() public returns (bool) {
        //获取该竞拍者已经出价的金额
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            //先将该竞拍者出价清空
            pendingReturns[msg.sender] = 0;
            //判断出价退回是否成功
            if (!payable(msg.sender).send(amount)) {
                //出价退回失败，恢复竞拍者出价金额
                pendingReturns[msg.sender] = amount;
                return false;
            }
            //触发出价退回成功事件
            emit BidWithdrawn(msg.sender, amount);
            return true;
        }
        return false;
    }

    //修饰器，限制某函数只能由合约部署者调用
    modifier onlyOwner() {
        require(
            msg.sender == deployer,
            "Only contract owner can call this function."
        );
        _;
    }

    /**拍卖结束函数*/
    function auctionEnd() public onlyOwner {
        //只有拍卖合约部署者才能调用拍卖结束函数
        // 判断竞拍是否已经结束了
        require(block.timestamp >= auctionEndTime, "Auction not yet ended.");
        // 判断竞拍本身是否已经结束，即是否已经调用过该函数结束了竞拍
        require(!ended, "auctionEnd has already been called.");
        bool allBidsReturned = true; // 检查是否所有出价都已退回
        uint256 reward = 0;
        // 退回未成功竞拍者的出价
        for (uint256 i = 0; i < bidders.length; i++) {
            if (bidders[i] != highestBidder) {
                uint256 amount = pendingReturns[bidders[i]];
                if (amount > 0) {
                    pendingReturns[bidders[i]] = 0;
                    if (!payable(bidders[i]).send(amount)) {
                        pendingReturns[bidders[i]] = amount;
                        //表示有出价退回失败
                        allBidsReturned = false;
                    }
                    //触发为竞拍失败者退回出价的事件
                    emit BidWithdrawn(bidders[i], amount);
                }
            }
        }
        // 将NFT转移给出价最高者，要求出价最高者地址不是0地址
        if (highestBidder != address(0)) {
            /**
            NFT管理者（即合约部署者）可以获得的奖励是本次拍卖最高价的5%，剩余95%转给本次拍卖受益者。
            因为调用拍卖结束函数需要大量的gas，简单以抽成5% (实际上的抽成奖励分配是动态的，算法很复杂，
            这里只是简单的模拟，取固定比例5%) 的这种方式补偿拍卖函数调用者（即拍卖合约部署者）
            并激励NFT拍卖平台管理者维护该拍卖平台
            */
            reward = (highestBid * 5) / 100;
            //将该被拍卖的NFT转移给出价最高者
            safeTransferFrom(ownerOf(tokenId), highestBidder, tokenId);
            //将最高出价转给拍卖受益者
            if (highestBid > 0) {
                beneficiary.transfer(highestBid - reward);
                //如果最高出价者多次出价，最后将最高出价者的非最高次叫价金额退回，即将最高出价者出最高价之前的出价退回
                if (pendingReturns[highestBidder] > 0) {
                    payable(highestBidder).transfer(
                        pendingReturns[highestBidder]
                    );
                }
            }
        }

        //检查是否所有出价都已退回,如果所有出价都退回了则 allBidsReturned=true
        if (allBidsReturned) {
            //竞拍结束标识符设置为true
            ended = true;
            //触发竞拍结束事件
            emit AuctionEnded(highestBidder, highestBid);
        }
        //奖励>0，将本次拍卖获得的奖励给拍卖平台管理者和维护者，即拍卖合约部署者
        if (reward > 0) {
            //将获得的奖励转给拍卖合约部署者
            payable(deployer).transfer(reward);
            //触发分发奖励的事件,以激励拍卖平台维护和管理NFT拍卖
            emit DistributeReward(deployer, reward);
        }
        //重置最高出价者地址为0地址
        highestBidder = address(0);
        //重置受益者地址为0地址
        beneficiary = payable(address(0));
        //重置最高出价金额为0
        highestBid = 0;
    }
}
