// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./contractos/ERC165.sol";
import "./interfaces/IERC721.sol";
import "./interfaces/IERC721Receiver.sol";

contract Token721 is ERC165, IERC721{

    /*Definir las variables de estado que van a llevar la logica y gestionan eñ NFT*/
    // Cual es la adrress dueña del token
    mapping (uint256 => address) private _owners;
    // Rerlacion de los tokens con las adress aproavdas para su gestion
    mapping (uint256 => address) private _tokenApprovals;
    // Cuantos tokens tiene una adrres
    mapping (address => uint256) private _balances;
    //Relacion de las adrres que pueden gestionar todos los tokens de las otras adreess
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    /*Bloque de codigo Funciones del 721*/
    /*si tienen _ es funcion interna que sera llamada dentro del mismo contrato*/
    function _safeMint(address to, uint256 tokenId) public{
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) public{
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721 Error, transfer 721Received implemented");//verificar quer la dfireccion sea compatible con los tokens 721
    }
    /*
        to = direccion dueña del token
        tokenId = identificador del token
        Esto es para crear y transferir ese token creado
        esta funicon solo es llamada desde las funciones que estan arriba
    */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721 Error, mint to the zero address"); //No puede ser una direccion vacia
        require(!_exist(tokenId), "ERC721 Error,Token already minted"); // No puede existir dos token cn el mismo ID
        
        _beforeTokenTransfer(address(0), to, tokenId); //Aqui es por si quieres hacer algun cambio , es precindible

        _balances[to] +=1; //sumamos balance
        _owners[tokenId] = to; //Identificamos dueño con el Id del token

        emit Transfer(address(0), to, tokenId); //Se transfiere el token
    }

    /*Validaciones*/
    function _checkOnERC721Received (address from, adreess to, uint256 tokenId, bytes memory data) private returns (bool){
        if(_isContract(to)){
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval){
                return retval == IERC721Receiver(to).onERC721Received.selector;
            }catch (bytes memory reasson){
                if(retval.length == 0){
                    revert("ERC721 Error, transfer 721Received implemented");
                }else{
                    assembly{
                        revert(add(32, reasson),mload(reasson))
                    }
                }
            }
        }  else{
            return true;
        }
    }

    function _isContract(address _addr) private view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function _exist(uint256 tokenId) private view returns (bool){
        return _owners[tokenId] !=  address(0);
    }

    function _beforeTokenTransfer(address from, adreess to, uint256 tokenId) internal virtual{

    }
}