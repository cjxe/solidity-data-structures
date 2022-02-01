// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.11;

contract LinkedList {
    struct Node {
        bytes32 next;
        uint256 data;
    }

    // "_" is used when declaring private variables
    mapping(bytes32 => Node) private _nodes;
    uint256 private _length;
    bytes32 private _head;
    bytes32 private _prevNodeId;

    constructor(uint256 data) {
        Node memory n = Node(_head, data);

        bytes32 id = keccak256(abi.encodePacked(data, _length, block.timestamp));

        _nodes[id] = n;
        _head = id;
        _prevNodeId = id;
        _length = 1;
    }

    function getNode(bytes32 id) public view returns(Node memory) {
        return _nodes[id];
        // Q: Why "getter func" instead of `public`?
        // A1: https://ethereum.stackexchange.com/questions/67137/why-creating-a-private-variable-and-a-getter-instead-of-just-creating-a-public-v
        // A2: Actually, there is no need since when we declare the variable as `public`, solidity already creates a getter function for it.
        // However, we declared the variable as private so a getter is needed.
        // For more: https://ethereum.stackexchange.com/a/25504/79733
    }

    function getLength() public view returns(uint256) {
        return _length;
    }

    function getHead() public view returns(bytes32) {
        return _head;
    }

    function addNode(uint256 data) public returns(bytes32) {
        Node memory n = Node(0, data);

        bytes32 id = keccak256(abi.encodePacked(data, _length, block.timestamp));

        _nodes[id] = n;
        _nodes[_prevNodeId].next = id;
        _prevNodeId = id;
        _length += 1;
        return id;
    }

    function popHead() private returns(bool) {
        bytes32 currHead = _head;

        _head = _nodes[currHead].next;

        // deleting is not necessary but we get partial refund
        delete _nodes[currHead];
        _length -= 1;
        return true;
    }

    function deleteNode(bytes32 id) public returns(bool) {
        if (_head == id) {
            popHead();
            return true;
        }

        bytes32 curr = _nodes[_head].next;
        bytes32 prev = _head;
        uint256 length = _length;
        
        // skipping node at index=0 (cuz its the head)
        for (uint256 i=1; i < length; i++) {
            if (curr == id) {
                _nodes[prev].next = _nodes[curr].next;
                delete _nodes[curr];
                _length -= 1;
                return true;
            }
            prev = curr;
            curr = _nodes[prev].next;
        }
        revert("Node ID not found.");
    }
}
