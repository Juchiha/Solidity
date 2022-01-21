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

    /*Funcion para que solo una persona púeda crear tokens*/

    /******/
    /*Funcion para soportar Interfaces, verificamos que las soporta*/
    /*Override => SobreEscribir*/
    /*Con super se llama la funcion de la interfas de IERC165 en contracts*/
    function supportsInterface(bytes interfaceId) public view virtual override(ERC165, IERC165) returns(bool){
        return interfaceId == type(IERC721).interfaceId || super.supportsInterface(interfaceId);
    }
    /*Accede al mappin de _balance y retirna cuantos tokens tiene una address que se le pasa como parametro*/
    function balanceOf(address owner) public view virtual override returns(uint256){
        require(owner != address(0), "ERC721 ERROR, ZERO ADDRESS"); //No se le puede pasar una addres vacia o incexistente!
        return _balances[owner];
    }

    /*Aprobar tokens y direcciones*/

    /*Recibe una addres a la que se quiere permiso yt  una identificador de token que es quie se le quiere dar
    permiso para que se le pueda transferir*/
    function approve(address to, uint tokenId)public virtual override{
        address owner = ownerOf(tokenId);//obtenermos el dueño de ese token
        require(to != owner, "ERROR ERC721, DESTINATION ADDRESS MUST BE DIFFERENT");///Si la direecion que se quiere dar permiso no puede ser la misma del dueño
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), // que el dueño del token sea quien este dando permiso o que tu tengas permiso de gestio de este
            "ERROR ERC721, YOU ARE NOT THE OWNER OR YOU DON'T HAVE PERMISSIONS"
        );
        _approved(to, tokenId); //se aprueba la transferencia y se adjudican los permisos
    }
    /*asignamos la adrres a la que quermos darle permiso y se hace un event approval*/
    function _approved(address to, uint256 tokenId)internal virtual{
       _tokenApprovals[tokenId] = to;
       emit Approval(ownerOf(tokenId), to, tokenId); //dueño, direccion a la que le damos permisos, y el token
    }

    /*Retorna el address dueño de ese token*/
    function ownerOf(uint256 tokenId)  public view virtual override returns(address){
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721 ERROR, TokenID no exist"); //No existe ese token que se la paso
        return owner;
    }

    function getApproved(uint256 tokenId) public view virtual override returns(address){
        require(_exist(tokenId), "ERC721 ERROR, TOKEN ID DOES NOT EXIST");
        return _tokenApprovals[tokenId];
    }
    /*Damos permiso a una address de ser dueño de todos nuestros tokens*/
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != msg.sender , "ERC721 ERROR, Operador Address must be different");//la address a la que quermos dar permisos de manejar nuestros tokens
        // debe ser difernete a la que esta haciendo la transaccion
        _operatorApprovals[msg.sender][operator] = approved; //Aprovamos
        emit ApprovalForAll(msg.sender, operator, approved);//emitimos el evento
    }

    /*validamos los permisos, poregunta si el oprator puede mover los tokens de esa billetera*/
    function isApprovedForAll(address owner, address operator) public view virtual override returns(bool){
        return _operatorApprovals[ownerOf][operator];
    }
    /**HASTA AQUI */
    
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
        /*POr defecto la dejamos vacia*/
    }


    /*Transferir Tokens BLoque de codigo*/

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override{
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override{
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721 ERROR, YOU DO NOT PERMISSIONS OR YOU NOT ARE THE OWNER");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual{
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721 Error, transfer 721Received implemented");
    }

    function transferFrom(address from, address to, uint256 tokenId)public virtual override{
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721 ERROR, YOU DO NOT PERMISSIONS OR YOU NOT ARE THE OWNER" );
        _transfer(from, to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERROR ERC721, TOKEN ID DOES NOT EXISTS");
        require(to != address(0), "ERROR ERC721, TRANSFER TO ZERO ADDRESS");
        _beforeTokenTransfer(from, to, tokenId);
        _approved(address(0), tokenId);
        _balances[from] -=1; //restamos balance
        _balances[to] += 1;
        _owners[tokenId] = to; //Identificamos dueño con el Id del token
        emit Transfer(address(0), to, tokenId); //Se transfiere el token
    }

    /*Hasta aqui*/
}