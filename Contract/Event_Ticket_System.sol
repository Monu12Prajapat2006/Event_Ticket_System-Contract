// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventTicketSystem {
    address public owner;

    struct Event {
        uint id;
        string name;
        string location;
        uint date;
        uint totalTickets;
        uint ticketsSold;
        uint ticketPrice;
        bool isActive;
    }

    struct Ticket {
        uint eventId;
        address owner;
    }

    uint public nextEventId;
    mapping(uint => Event) public events;
    mapping(address => Ticket[]) public ticketsOwned;

    event EventCreated(uint eventId, string name, uint totalTickets, uint ticketPrice);
    event TicketPurchased(uint eventId, address buyer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createEvent(
        string memory _name,
        string memory _location,
        uint _date,
        uint _totalTickets,
        uint _ticketPrice
    ) public onlyOwner {
        require(_date > block.timestamp, "Event date should be in the future.");
        require(_totalTickets > 0, "Total tickets should be more than zero.");

        events[nextEventId] = Event(
            nextEventId,
            _name,
            _location,
            _date,
            _totalTickets,
            0,
            _ticketPrice,
            true
        );

        emit EventCreated(nextEventId, _name, _totalTickets, _ticketPrice);
        nextEventId++;
    }

    function buyTicket(uint _eventId) public payable {
        Event storage myEvent = events[_eventId];
        require(myEvent.isActive, "Event is not active.");
        require(myEvent.date > block.timestamp, "Event has already occurred.");
        require(myEvent.ticketsSold < myEvent.totalTickets, "All tickets are sold.");
        require(msg.value == myEvent.ticketPrice, "Incorrect ticket price.");

        myEvent.ticketsSold++;
        ticketsOwned[msg.sender].push(Ticket(_eventId, msg.sender));

        emit TicketPurchased(_eventId, msg.sender);
    }

    function getMyTickets() public view returns (Ticket[] memory) {
        return ticketsOwned[msg.sender];
    }

    function deactivateEvent(uint _eventId) public onlyOwner {
        events[_eventId].isActive = false;
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}

