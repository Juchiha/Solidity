// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC165.sol";

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);//Cuantos tokens hay en una direccion
    function ownerOf(uint256 tokenId) external view returns (address owner); //Identificador quin es el dueño del toeken
    function approve(address to, uint256 tokenId) external; //Delegar la capacidad de gestionar un Token a otra direccion
    function getApproved(uint256 tokenId) external view returns (address operator); //Informacion respectiva de aprove
    function setApprovalForAll(address operator, bool _approved) external; //permite a una direccion manejar todos los tokens
    function isApprovedForAll(address owner, address operator) external view returns (bool);//Quien tiene permitido o manejar todos los tokens
    /*Transferencia de Tookens*/
    function transferFrom(address from, address to, uint256 tokenId) external;//transferencia de una direccion a otra
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}