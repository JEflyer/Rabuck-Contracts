//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//this allows us to use functions like walletOfOwner which is a great tool 
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./interfaces/IStats.sol";

import "./libraries/minterLib.sol";

contract Minter is ERC721Enumerable {
    //events
    event Mint(address to, uint16 tokenId);
    event AdminChange(address newAdmin);
    event PriceIncrease(uint256 newPrice);


    //variables
    address private admin;
    address private statContract;

    bool private active;

    string private baseURI;
    string private CID;
    string private extension;
    string private notRevealed;
    bool private revealed;

    uint256 private price;
    uint16 mintLimit;
    uint16 currentAmountMinted;

    address[] private paymentsTo;
    uint16[] private shares;

    
    //constructor
    constructor(
        address[] memory _paymentsTo,
        uint16[] memory _shares,
        string memory _base,
        string memory _extension,
        string memory _notRevealed,
        string memory _CID,
        uint8 _priceInEth
    ) ERC721("Rabuck","Buck"){
        require(_paymentsTo.length == _shares.length,"Invalid inputs");
        active = false;
        price = _priceInEth * 10**18;
        admin = _msgSender();
        mintLimit = 10000;
        currentAmountMinted = 0;
        baseURI = _base;
        extension = _extension;
        notRevealed = _notRevealed;
        CID = _CID;
    }

    //modifiers
    modifier onlyAdmin {
        require(_msgSender() == admin);
        _;
    }
    
    //admin functions
    function setBase(string memory _base) public onlyAdmin {
        baseURI = _base;
    } 

    function setCID(string memory _CID) public onlyAdmin {
        CID = _CID;
    }

    function setNotRevealed(string memory _not) public onlyAdmin {
        notRevealed = _not;
    }

    function unreveal() public onlyAdmin {
        revealed = true;
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        admin = _newAdmin;
    }

    function updatePayments(address[] memory _to, uint16[] memory _shares) public onlyAdmin {
        require(_to.length == _shares.length, "invalid inputs");
        paymentsTo = _to;
        shares = _shares;
    }

    function flipSaleState() public onlyAdmin {
        active = !active;
    }

    function setStatContract(address _statContract) public onlyAdmin {
        statContract = _statContract;
    }

    //payment split
    function splitFunds(uint256 amount) public payable {
        uint16 divider = minterLib.getDiv(shares);

        for(uint i =0; i<paymentsTo.length; i++){
            require(payable(paymentsTo[i]).send(amount * shares[i]/ divider));
        }
    }

    //receive
    receive() external payable {
        splitFunds(msg.value);
    }


    //ERC721 URI Override
    function tokenURI(uint16 _tokenId) public view virtual returns(string memory uri){
        require(_exists(_tokenId));
        if(!revealed){uri = string(abi.encodePacked(baseURI, notRevealed));}
        else {uri = string(abi.encodePacked(baseURI, CID, string(abi.encodePacked(_tokenId)), extension));}
    }
    
    //main functions
    function mint (uint8 amount) public payable {
        require(active);
        require(amount <= 10);
        require(amount+currentAmountMinted <= mintLimit);
        if(_msgSender() != admin) {
            require(msg.value == getPrice(amount));
            if(minterLib.crossesThreshold(amount, currentAmountMinted)){
                price = minterLib.updatePrice(price);
            }
            splitFunds(msg.value);
        }

        for(uint8 i = 0; i< amount; i++) {
            currentAmountMinted +=1;
            _mint(_msgSender(), currentAmountMinted);
        }
    }



    //returns an array of tokens held by a wallet
    function walletOfOwner(address _wallet) public view  returns(uint16[] memory ids){
        uint16 ownerTokenCount = uint16(balanceOf(_wallet));
        ids = new uint16[](ownerTokenCount);
        for(uint16 i = 0; i< ownerTokenCount; i++){
            ids[i] = uint16(tokenOfOwnerByIndex(_wallet, i));
        }
    }

    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId));
        _burn(tokenId);
    }

    function getPrice(uint8 amount) public view returns (uint256) {
        require(amount <= 10, "Err: Too high");
        return minterLib.getPrice(amount, price, currentAmountMinted);
    }

}