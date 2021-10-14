// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
pragma experimental ABIEncoderV2;

/*
* NOMBRES      | EDAD  | IDENTIFICACION |
* JOSE RAMON   | 31     123456X
* NEIMAR JR    | 20     123457X
* ATANACION G  | 91     123458X
* CINDY BLANCO | 34     123459X
* LEONARDO L   | 25     123450X
*/

contract Votaciones{
    // Direccion del propietario del contrato
    address public owner;
    
    constructor() public {
        owner = msg.sender;//el que despliege el contrato es el dueño
    }
    //relacion entre el nomnre del candidato y el hash de sus datos personales
    mapping (string => bytes32) Id_Candidato;
    
    //relacion entre el nombre del candidato y el numero de botos
    mapping (string => uint) vtos_candidato;
    
    //lista de todos los candidatos
    string[] candidatos;
    
    //lista de los votantes=> hash de los votantes
    bytes32[] votantes;
    
    //Cualquier persona puede presentarse a las elecciones y ser candidatos
    function Representar(string memory _nombrePersona, uint _edadPersona, string memory _idPersona) public {
        //Calcular el HASH de los datos del candidato
        bytes32 hash_candidato = keccak256(abi.encodePacked(_nombrePersona, _edadPersona, _idPersona));
        //almacenar sus datos en el array
        Id_Candidato[_nombrePersona] = hash_candidato;
        //actualizar la lista de los candidatos
        
    }   
    
}