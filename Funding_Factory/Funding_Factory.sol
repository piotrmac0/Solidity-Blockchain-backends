pragma solidity ^0.4.17;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint256 minimum) public {
        //msg.sender is a user who is creating a new campaign
        address newCampaign = new Campaign(minimum, msg.sender); //newCampaign = new instance of contract Campaign
        deployedCampaigns.push(newCampaign); //add address of new campaign to array address
    }

    function getDeployedCampaigns() public view returns (address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint256 value;
        address recipient;
        bool complete;
        uint256 approvalCount; //number of voters, minimum must be 50% of approvers
        mapping(address => bool) approvals; // track who has votes
    }

    Request[] public requests;
    address public manager;
    uint256 public minimumContribution;
    mapping(address => bool) public approvers;
    uint256 public approversCount; //number of approvers from mapping

    modifier restricted() {
        //require that whoever called this function must be owner of contract
        require(msg.sender == manager);
        _;
    }

    constructor(uint256 minimum, address creator) public {
        // constructor
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution);

        approvers[msg.sender] = true; //adding address to mapping and value true
        approversCount++;
    }

    function createRequest(
        string description,
        uint256 value,
        address recipient
    ) public restricted {
        //creating new struct
        Request memory newRequest = Request({ // (Request)get ready to create new variable that'll store 'Request' (newRequest)name of variable = Request({}) create news instance of Request
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });

        requests.push(newRequest);
    }

    function approveRequest(uint256 index) public {
        //index of the request we're tring to approve

        Request storage request = requests[index];

        require(approvers[msg.sender]); //must be true, approver must contribute
        require(!requests[index].approvals[msg.sender]); //if user voted before, he can't do it second time

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint256 index) public restricted {
        Request storage request = requests[index]; //this variable should use same variable as in storage

        require(request.approvalCount > (approversCount / 2)); //minimum of approval votes for finalizing request
        require(!request.complete);

        request.recipient.transfer(request.value); //sending money - value from struct, to recipient with method transfer
        request.complete = true;
    }
}
