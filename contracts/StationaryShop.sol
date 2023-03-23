// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract StationaryShop {
    enum bookAvailable {
        available,
        notAvailable
    }

    enum bookStock {
        inStock,
        outOfStock
    }

    bookAvailable public currentBookAvailabilityStatus;
    bookStock public currentBookStockStatus;

    // event BookStockUpdated(uint indexed bookId, uint newAmount);

    // making a struct of Book
    // it has id, title, author, price and the amount of book
    // 220, Intro to web3.0, David, 1, 30
    // 50, CS50, David J. Malan, 2, 100
    struct Book {
        uint id;
        string title;
        string author;
        uint price;
        uint amount;
    }


    // initializing a public value for the address of the owner
    uint public totalBooks = 0; // totalBooks that will be in the shop
    address payable public owner; // address of the owner that is payable
    // mapping(uint => Book) public booksDescription; // mapping uint to Book object
    Book[] public stationaryShopBooks; // array that stores all the books in the shop
    // mapping(address => uint) bookNumbers; 


    constructor() {
        owner = payable(msg.sender); // sets the owner to be the one who deploys the contract
        currentBookAvailabilityStatus = bookAvailable.notAvailable;
        currentBookStockStatus = bookStock.outOfStock;
    }


    // making a modifier that allows only the owner to add books to the shop
    modifier onlyOwnerCanAdd {
        require(msg.sender == owner, "Only the owner can add new books.");
        _;
    }


    // adds book to the shop. Only the owner can add.
    function addBook(
        uint _id, 
        string memory _title, 
        string memory _author, 
        uint _price, 
        uint _amount
    )
    public onlyOwnerCanAdd {
        // adds the struct to the mapping booksDescription with an id that starts with 0 
        // booksDescription[uint(totalBooks)] = Book(_id, _title, _author, _price, _amount);
        
        // pushing the Book struct with the id, title, author, price, amount to the array stationaryShopBooks
        stationaryShopBooks.push(Book(_id, _title, _author, _price, _amount));
        
        // assigning the totalBooks to be the length of stationaryShopBooks
        totalBooks = stationaryShopBooks.length;

        // bookNumbers[address(this)] = stationaryShopBooks.length;
    }


    // function that lets other purchase book
    function purchaseBook(
        uint _id, 
        uint _requestedNumberOfBooks
    ) public payable {
        uint _indexOfBook;
        uint _price;
        uint _totalPrice;

        // checking if the provided id of the book is available or not
        // also checking if the provided amount of books are available or not
        for (uint i = 0; i < stationaryShopBooks.length; i++) {
            if (_id == stationaryShopBooks[i].id) {
                _indexOfBook = i; 
                currentBookAvailabilityStatus = bookAvailable.available;
                if (_requestedNumberOfBooks > stationaryShopBooks[i].amount) {
                    currentBookStockStatus = bookStock.outOfStock;
                } else {
                    currentBookStockStatus = bookStock.inStock;
                    _price = stationaryShopBooks[i].price;
                    _totalPrice = _price * _requestedNumberOfBooks;
                }
            }
        }

        // requiring that the books are available and are in stock
        require(currentBookAvailabilityStatus == bookAvailable.available, "There is no such book in the store.");
        require(currentBookStockStatus == bookStock.inStock, "There are not that many numbers of book in stock right now.");

        // requiring that the amount to be greater or equal to the price of a book
        require(msg.value >= _totalPrice * 1 ether, "Not enough ether provided.");

        // transferring the money to owners address
        owner.transfer(msg.value);

        // updating the book's information
        updateBooksInfo(_indexOfBook, _requestedNumberOfBooks);
    }

    // function that will update the value of the items
    function updateBooksInfo(
        uint _index,
        uint _numberOfBooks
    ) internal  {
        for (uint i = 0; i < stationaryShopBooks.length; i++) {
            if (_index == i) {
                stationaryShopBooks[i].amount = stationaryShopBooks[i].amount - _numberOfBooks;
                // emit BookStockUpdated(stationaryShopBooks[i].id, stationaryShopBooks[i].amount);
            }
        }
    }


    // returns the books available in the shop
    function getStationaryBookStock() public view returns (Book[] memory) {
        return stationaryShopBooks;
    }
}