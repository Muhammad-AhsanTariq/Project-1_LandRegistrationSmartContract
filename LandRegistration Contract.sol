// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

    contract LandRegistry{
   
    struct Landreg{
        uint LandId;
        uint Area;
        string City;
        string State;
        uint Landprice;
        uint PropertyPID;
    }

    struct Buyer{
        address Id;
        string Name;
        uint Age;
        string City;
        uint CNIC;
        string Email;
    }

    struct Seller{
        address Id;
        string Name;
        uint Age;
        string City;
        uint CNIC;
        string Email;
    }

    struct LandInspector{
        address Id;
        string Name;
        uint Age;
        string Designation;
    }

  
    //key value pairs
    mapping(uint => Landreg) private Land;
    mapping(uint => LandInspector) public InspectorMapping;
    mapping(address => Seller) private SellerMapping;
    mapping(address => Buyer) private BuyerMapping;
    mapping(address => bool) private RegisteredAddressMapping;
    mapping(address => bool) private RegisteredSellerMapping;
    mapping(address => bool) private RegisteredBuyerMapping;
    mapping(address => bool) private SellerVerification;
    mapping(address => bool) private SellerRejection;
    mapping(address => bool) private BuyerVerification;
    mapping(address => bool) private BuyerRejection;
    mapping(uint => bool) private LandVerification;
    mapping(uint => address) private LandOwner;
    mapping(uint => bool) private PaymentReceived;

    
    address[] private sellers;
    address[] private buyers;

    event Registration(address _registrationId);
    event Verified(address _id);
    event Rejected(address _id);

   //(LandInspector)
   address public _landInspector;
     
    constructor() {
        _landInspector = msg.sender ;
    }
    modifier onlyme() {
       require( _landInspector == msg.sender , "LandInspector Restricted");
       _;
    }
    
    uint inspector;
    
    function addlandInspector(address _id,string memory _name, uint _age, string memory _designation) public onlyme{

      InspectorMapping[inspector] = LandInspector(_id,_name, _age, _designation);
    }
    
    function landInspector(address) private view returns (bool) {
        if(msg.sender==_landInspector){
            return true;
        }else{
            return false;
        }
    }
    
    // (SELLER)   
    // Registration of seller
    
    uint private sellersCount;
    function registerSeller(string memory _name, uint _age, string memory _city, uint _cnic, string memory _email) public {
        //require that Seller is not already registered
        require(!RegisteredAddressMapping[msg.sender]);

        RegisteredAddressMapping[msg.sender] = true; // it will register player
        RegisteredSellerMapping[msg.sender] = true ;
        sellersCount++;
        SellerMapping[msg.sender] = Seller(msg.sender,_name, _age, _city,_cnic, _email);
        sellers.push(msg.sender);
        emit Registration(msg.sender);
    }
    
    function verifySeller(address _sellerId) public{
        require(landInspector(msg.sender));

        SellerVerification[_sellerId] = true;
        emit Verified(_sellerId);
    }

    function rejectSeller(address _sellerId) public{
        require(landInspector(msg.sender));

        SellerRejection[_sellerId] = true;
        emit Rejected(_sellerId);
    }
    
    function SellerisVerified(address _id) public view returns(bool) {
        if(SellerVerification[_id]){
            return true;
        }
        else{return false;} 
        
    }
    
    function isSeller(address _id) public view returns (bool) {
        if( SellerVerification[_id]){
            return true;
        }
        else{return false;}
    }

    //Add Land
    uint private landsCount;
    function addLand(uint _landId,uint _area, string memory _city,string memory _state, uint _landPrice, uint _propertyPID) public {
        require((isSeller(msg.sender)));
        landsCount++;

        Land[_landId] = Landreg(_landId,_area, _city, _state,_landPrice,_propertyPID);
        LandOwner[_landId]=msg.sender;
        
    }
    
    function verifyLand(uint _landId) public{
        require(landInspector(msg.sender));

        LandVerification[_landId] = true;
    }

    function isLandVerified(uint _landId) public view returns (bool) {
        if(LandVerification[_landId]){
            return true;
        }
        else {return false;}
    }
    
    function updateSeller(string memory _name, uint _age, string memory _city, uint _cnic, string memory _email) public {
        //require that Seller is already registered
        require(RegisteredAddressMapping[msg.sender] && (SellerMapping[msg.sender].Id == msg.sender));
        
        SellerMapping[msg.sender].Name = _name;
        SellerMapping[msg.sender].Age = _age;
        SellerMapping[msg.sender].City = _city;
        SellerMapping[msg.sender].CNIC = _cnic;
        SellerMapping[msg.sender].Email = _email;

    }
    function getArea(uint _landId) public view returns (uint) {
        return  Land[_landId].Area;
    }
    
    function getLandCity(uint _landId) public view returns (string memory) {
        return Land[_landId].City;
    }
    
    function getLandPrice(uint _landId) public view returns (uint) {
        return Land[_landId].Landprice;
    }
    
    function LandsOwner(uint _landId) public view returns (address) {
        return LandOwner[_landId];
    }

    // (BUYER)
    // Registration of Buyer
    uint private buyersCount;
    function registerBuyer(string memory _name, uint _age, string memory _city, uint _cnic, string memory _email) public {
        //require that Buyer is not already registered
        require(!RegisteredAddressMapping[msg.sender]);

        RegisteredAddressMapping[msg.sender] = true;
        RegisteredBuyerMapping[msg.sender] = true ;
        buyersCount++;
        BuyerMapping[msg.sender] = Buyer(msg.sender, _name, _age, _city, _cnic, _email);
        buyers.push(msg.sender);

        emit Registration(msg.sender);
    }
    
    function verifyBuyer(address _buyerId) public{
        require(landInspector(msg.sender));

        BuyerVerification[_buyerId] = true;
        emit Verified(_buyerId);
    }

    function rejectBuyer(address _buyerId) public{
        require(landInspector(msg.sender));

        BuyerRejection[_buyerId] = true;
        emit Rejected(_buyerId);
    }
    
    function BuyerisVerified(address _id) public view returns (bool) {
        if(BuyerVerification[_id]){
            return true;
        }
        else{return false;}
    }
    
    function updateBuyer(string memory _name,uint _age, string memory _city,uint _cnic, string memory _email) public {
        //require that Buyer is already registered
        require(RegisteredAddressMapping[msg.sender] && (BuyerMapping[msg.sender].Id == msg.sender));

        BuyerMapping[msg.sender].Name = _name;
        BuyerMapping[msg.sender].Age = _age;
        BuyerMapping[msg.sender].City = _city;
        BuyerMapping[msg.sender].CNIC = _cnic;
        BuyerMapping[msg.sender].Email = _email;   
    }
    
    function isBuyer(address _id) public view returns (bool) {
        if(BuyerVerification[_id]){
            return true;
        }
        else {return false;
        }
    }

    function getSeller() public view returns( address [] memory ){
        return(sellers);
    }
    function getBuyer() public view returns( address [] memory ){
        return(buyers);
    } 
    function getSellerDetails(address i) public view returns (string memory, uint, string memory, uint, string memory) {
        return ( SellerMapping[i].Name, SellerMapping[i].Age, SellerMapping[i].City, SellerMapping[i].CNIC, SellerMapping[i].Email);
    }
    function getBuyerDetails(address i) public view returns ( string memory,uint, string memory, uint, string memory) {
        return (BuyerMapping[i].Name,BuyerMapping[i].Age , BuyerMapping[i].City, BuyerMapping[i].CNIC, BuyerMapping[i].Email);
    }


    // (Land Buy and Transfer)
   
    function BuyLand(uint _landId)  public payable{  
        PaymentReceived[_landId] = true;  
        
        require(msg.value==Land[_landId].Landprice , "Price Issue)");
         payable (LandOwner[_landId]).transfer(msg.value);
        require(BuyerMapping[msg.sender].Id == msg.sender ,"Not registered Buyer");
        require(PaymentReceived[_landId], "not paid");
        LandOwner[_landId] = msg.sender;
    }

    function isLandPaid(uint _landId) public view returns (bool) {
        if(PaymentReceived[_landId]){
            return true;
        }
        else {return false;
        }
    }
    
    // (Seller can also transfer land ownership to whom he want)
    
    function LandOwnershipTransfer(uint _landId, address _newOwner) public{
         require((SellerMapping[msg.sender].Id == msg.sender) , "only seller allowed");{
         LandOwner[_landId] = _newOwner;
         }
    }
    
}
