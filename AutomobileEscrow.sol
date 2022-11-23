//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC721{
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract AutomobileEscrow {

    address public nftAddress;
    uint256 public nftID;
    uint256 public price;
    uint256 public downPayment;
    address payable public  buyer;
    address payable public  owner;
    address payable public roadTransportAuthority;
    address payable public lender;

    bool public roadTransportAuthorityApproval=false;
    bool public lenderApproval=false;
 //   mapping(address=>bool) public approval;

    constructor(address _nftAddress, uint256 _nftID, uint256 _price, uint256 _downPayment, address payable _owner, address payable _buyer,  address payable _roadTransportAuthority, address payable _lender) {
        nftAddress = _nftAddress;
        nftID = _nftID;
        price = _price;
        downPayment = _downPayment;
        owner = _owner;
        buyer = _buyer;
        roadTransportAuthority = _roadTransportAuthority;
        lender = _lender;
    }

    modifier onlyRTA(){
        require(msg.sender==roadTransportAuthority);
        _;
    }
    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }

    modifier onlylender(){
        require(msg.sender==lender);
        _;
    }
    modifier onlyBuyer(){
        require(msg.sender==buyer);
        _;
    }


    function depositDownPayment() payable public onlyBuyer{
        require(msg.value>= downPayment);
    }
    
    function RTAApprove(bool decision) public onlyRTA{
        roadTransportAuthorityApproval= decision;
    }

    function lenderApprove(bool decision) public onlylender{
        lenderApproval=decision;
    }

    function depositFunding() payable public onlylender{
        require(msg.value>= price-downPayment);
    }


//    function approveSale() public {
//        approval[msg.sender] = true;
//    }

    function finalizeSale() public onlyOwner{
        require(roadTransportAuthorityApproval);
        require(lenderApproval);
  //      require((approval[owner]));
  //      require((approval[buyer]));
        require(address(this).balance>= price);

        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success);
        
        IERC721(nftAddress).safeTransferFrom(owner, buyer, nftID);

    }

    // Cancel Sale (handle earnest deposit)
    // -> if inspection status is not approved, then refund, otherwise send to seller
    function cancelSale() public {
        if(roadTransportAuthorityApproval == false) {
            payable(buyer).transfer(address(this).balance);
        } else {
            payable(owner).transfer(address(this).balance);
        }

        if(lenderApproval == false) {
            payable(buyer).transfer(address(this).balance);
        } else {
            payable(owner).transfer(address(this).balance);
        }
    }

    receive() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

}



