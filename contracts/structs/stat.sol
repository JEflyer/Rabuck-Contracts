//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract StatContract is ChainlinkClient{

    using Chainlink for Chainlink.Request;
    event upgradedStats(Stats _stats);
    
    string[] statNames = [
        "Damage",
        "DamageResistance",
        "Stun",
        "Agility",
        "Healing",
        "Swagness",
        "Rarity",
        "Main Role",
        "Sub Role"
    ];
    
    struct Stats{
        uint16 health;
        uint16 damage;
        uint16 damageResistance;
        uint16 stun;
        uint16 agility;
        uint16 healing;
        uint16 swagness;
        uint8 rarity;
    }
    //rarity
    //0 - lowest rarity
    //4 - highest rarity

    mapping(uint16 => Stats) rabuckStats;
    //token Id => Stats

    //for keeping track of what request a request is for
    struct Requests {
        uint8 statBeingUpdated;
        uint16 tokenId;
    }

    mapping(bytes32 => Requests) requestData;

    //full link minus tokenID
    string private baseURI;

    //for accepting metadata pull requests for a tokenID from minterContract
    address private minterContract;

    //used for resetting the stats of a token if needed
    address private admin;

    //oracle variables
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    //for traversing through the metadata
    string private basePath;

    constructor(
        address _minter,
        string memory _base,
        address _oracle,
        bytes32 _jobId,
        uint256 _fee,
        string memory _basePath
    ){
        setPublicChainlinkToken();
        basePath = _basePath;
        oracle=_oracle;
        jobId = _jobId;
        fee = _fee;
        baseURI = _base;
        minterContract = _minter;
    }

    modifier onlyMinterContract{
        require(msg.sender == minterContract);
        _;
    }

    function getAndSet(uint16 tokenId) external onlyMinterContract{
        bytes32 _requestId0 = callForStat(tokenId, 0);
        requestData[_requestId0] = Requests(0,tokenId);

        bytes32 _requestId1 = callForStat(tokenId, 1);
        requestData[_requestId1] = Requests(1,tokenId);

        bytes32 _requestId2 = callForStat(tokenId, 2);
        requestData[_requestId2] = Requests(2,tokenId);

        bytes32 _requestId3 = callForStat(tokenId, 3);
        requestData[_requestId3] = Requests(3,tokenId);

        bytes32 _requestId4 = callForStat(tokenId, 4);
        requestData[_requestId4] = Requests(4,tokenId);

        bytes32 _requestId5 = callForStat(tokenId, 5);
        requestData[_requestId5] = Requests(5,tokenId);



        //these calls are for strings, rarity, mainRole & subRole
        bytes32 _requestId6 = callForStat(tokenId, 6);
        bytes32 _requestId7 = callForStat(tokenId, 7);
        bytes32 _requestId8 = callForStat(tokenId, 8);

    }

    function callForStat(uint16 tokenId, uint8 selection) internal returns(bytes32){
        if(selection < 6){
            Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this),this.fulfill.selector);

            request.add("get",string(abi.encodePacked(baseURI, string(abi.encodePacked(tokenId)))));
            request.add("path", string(abi.encodePacked(basePath, statNames[selection])));

            return sendChainlinkRequestTo(oracle, request, fee);
        }else {

        }

    }

    function fulfill(bytes32 _requestId, uint16 stat) public recordChainlinkFulfillment(_requestId){
        Requests memory data = requestData[_requestId];

        if(data.statBeingUpdated == 0){
            rabuckStats[data.tokenId].damage = stat;
        }
        if(data.statBeingUpdated == 1){
            rabuckStats[data.tokenId].damageResistance = stat;
        }
        if(data.statBeingUpdated == 2){
            rabuckStats[data.tokenId].stun = stat;
        }
        if(data.statBeingUpdated == 3){
            rabuckStats[data.tokenId].agility = stat;
        }
        if(data.statBeingUpdated == 4){
            rabuckStats[data.tokenId].healing = stat;
        }
        if(data.statBeingUpdated == 5){
            rabuckStats[data.tokenId].swagness = stat;
        }
        
    }

    function fulfillSpecial(bytes32 _requestId, string memory answer) public recordChainlinkFulfillment(_requestId) {
        Requests memory data = requestData[_requestId];

        if(data.statBeingUpdated == 6){

        }
        if(data.statBeingUpdated == 7){

        }
        if(data.statBeingUpdated == 8){

        }
    }

}