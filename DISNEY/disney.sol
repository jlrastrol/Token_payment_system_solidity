// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Disney {

    // ----------------------- DECLARACIONES INICIALES -----------------------

    // Instancia del contrato token
    ERC20Basic private token;

    // Dirección de Disney
    address payable public owner;

    // Estructura de datos para almacenar a los clientes de Disney
    struct cliente {
        uint token_comprados;
        string [] atracciones_disfrutadas;
    }

    // Mapping para el registro de clientes
    mapping (address => cliente) public clientes;

    // Constructor 
    constructor () public {
        token = new ERC20Basic(10000);
        owner = msg.sender;
    }

    // ----------------------- GESTIÓN DE TOKENS -----------------------

    // Función para establecer el precio de un token
    function precioToken(uint _numTokens) internal pure returns (uint){
        // Conversión de Tokens a Ethers: 1 Token -ª 1 Ether
        return _numTokens * (1 ether);

    }

    // Función para comprar Tokens en disney y disfrutar de las atracciones
    function comprarTokens(uint _numTokens) public payable{
        // Establecer el precio de los tokens
        uint coste = precioToken(_numTokens);
        // Se evalua el dinero que el cliente paga por los Tokens
        require(msg.value >= coste, "Compra menos Tokens o paga con mas ethers.");
        // Obtención del número de tokens disponibles
        uint balance = balanceOf();
        require(_numTokens <=balance, "Compra un número menos de Tokens");
        // Diferencia de lo que el cliente paga
        uint returnValue = msg.value - coste;
        // Disney retoena la cantidad de ethers al cliente
        msg.sender.transfer(returnValue);
        // Se transfiere el número de Tokens al cliente
        token.transfer(msg.sender, _numTokens);
        // Registro de tokens comprados
        clientes[msg.sender].token_comprados = _numTokens;
        
    }

    // Balance tokens del contrato Disney
    function balanceOf() public view returns (uint){
        return token.balanceOf(address(this));
    }

    // Visualizar el número de tokens restantes de un Cliente
    function misTokens() public view returns (uint){
        return token.balanceOf(msg.sender);
    }

    // Funcion para generar mas tokens
    function generarTokens(uint _numTokens) public unicamente(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }

    // Modificador para controlar las funciones ejecutables por disney
    modifier unicamente( address _direccion){
        require(_direccion == owner, "No tienes permisos para ejecutar esta función.");
        _;
    }

}