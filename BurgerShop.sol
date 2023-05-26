// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract BurgerShop { 
        uint256 public normalBurgerCost = 0.2 ether;
        uint256 public deluxBurgerCost = 0.4  ether;
        address public owner;
        //uint256 startDate = block.timestamp + 7 days;
        uint256 startDate = block.timestamp + 30 seconds;

        mapping (address => uint256) public userRefunds;

     //   uint256 public burgerCount =   100;

        //check interaction patters


    //THERE ARE 3 WAYS TO TRANSFER ETHER
  //  transfer (2300 gas, throws error)
// send (2300 gas, returns bool)
// call (forward all gas or set gas, returns bool)

        event BoughtBurger(address indexed _from, uint256 cost);

        //enum is used for STATE MACHINE......
            enum Stages {
                readyToOrder, //0
                makeBurger, //1
                deliverBurger //2
            }

        Stages public burgerShopStage = Stages.readyToOrder;
        

        constructor(){
            owner = msg.sender;
        }

        modifier shopOpened(){
            require(block.timestamp >  startDate, "Not opened yet");
            _;   
        }

         modifier onlyOwner(){
            require(msg.sender == owner, "Not the owner");
            _;   
        }


        modifier shouldPay(uint256 _cost) {
             require(msg.value >= _cost, "Not enough funds to buy burger");
             _;
        }

        modifier isAtStage(Stages _stage){
            require(burgerShopStage == _stage, "Not at the correct stage");
            _;
        }

        function buyBurger() payable public shouldPay(normalBurgerCost) isAtStage(Stages.readyToOrder) shopOpened {
            
           // require(msg.value == normalBurgerCost);     
           updateStage(Stages.makeBurger);
           //      burgerCount--;
            emit BoughtBurger(msg.sender, normalBurgerCost);
                      //old way of transferring ether..........
           //  payable(msg.sender).transfer(200000000);
        }

        function buyDekuxBurger() payable public shouldPay(deluxBurgerCost) shopOpened{
           
           updateStage(Stages.makeBurger);
            emit BoughtBurger(msg.sender, deluxBurgerCost);
           
        }

        function refund(address _to, uint256 _cost) payable public onlyOwner  {
           
           require(_cost == normalBurgerCost || _cost == deluxBurgerCost, "You are tyring refund the wrong amount");
           require(address(this).balance >= _cost, "Not enough funds");

           userRefunds[_to] = _cost;
    //        uint256 balanceBeforeTransfer = address(this).balance;
       
    //    //revert is used for more complex logics and it reverts back the logic from the begining.............
            
    //         // assert it to reconfirm and check for likely error in the logic
    //         assert(address(this).balance == balanceBeforeTransfer - _cost);

        }


        function claimRefund() payable public {
            uint256 value = userRefunds[msg.sender];

            userRefunds[msg.sender] = 0;
            (bool success, ) = payable(msg.sender  ).call{value: value}("");
                    require(success);
        }



        function getFunds() public view returns(uint256){
            return address(this).balance;
        }

         function madeBurger() public isAtStage(Stages.makeBurger) shopOpened {
            updateStage(Stages.deliverBurger);
        }

        function pickUpBurger() public isAtStage(Stages.deliverBurger) shopOpened {
            updateStage(Stages.readyToOrder);
        }

        function updateStage(Stages _stage) public {
            burgerShopStage = _stage;
        }

        function getRandomNum(uint256 _seed) public view returns(uint256){

            //modulus 10 will give random number btw 0 and 9
            //keccak256 will hash for us
            uint256 randNum = uint256(keccak256(abi.encodePacked(block.timestamp, _seed))) % 10 +1;
            return randNum;
        }

}