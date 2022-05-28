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
        string [] comidas_disfrutadas;
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
        // Conversión de Tokens a Ethers: 1 Token -> 0,001 Ether
        return _numTokens * (0.001 ether);

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
        clientes[msg.sender].token_comprados += _numTokens;
        
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

    // ----------------------- GESTIÓN DE DISNEY -----------------------

    // Eventos 
    event disfruta_atraccion(string, uint, address);
    event nueva_atraccion(string, uint);
    event baja_atraccion(string);

    event disfruta_comida(string, uint, address);
    event nueva_comida(string, uint);
    event baja_comida(string);

    // Estructura de la atracción
    struct atraccion {
        string nombre_atraccion;
        uint precio_atraccion;
        bool estado_atraccion;
    }

    // mapping para relacionar un nombre de una atracción con una estructura de datos de la atracción
    mapping(string => atraccion) public mappingAtracciones;

    // Array para almacenar el nombre de las atracciones
    string[] atracciones;

    // Mapping para relaccionar un cliente con su historial en DISNEY
    mapping(address => string[]) historialAtracciones;

    // Estructura de la comida
    struct comida {
        string nombre_comida;
        uint precio_comida;
        bool estado_comida;
    }

    // mapping para relacionar un nombre de una atracción con una estructura de datos de la atracción
    mapping(string => comida) public mappingComidas;

    // Array para almacenar el nombre de las comidaes
    string[] comidas;

    // Mapping para relaccionar un cliente con su historial en DISNEY
    mapping(address => string[]) historialComidas;

    // Star Wars -> 2 Tokens
    // Toy Story -> 5 Tokens 
    // Piratas del Caribe -> 8 Tokens 

    // Crear nuevas atracciones para DISNEY (SOLO es ejecutable por Disney)
    function nuevaAtraccion(string memory _nombre, uint _precio) public unicamente(msg.sender){
        // Creación de una atracción en Disney
        mappingAtracciones[_nombre] = atraccion(_nombre,_precio,true);
        // Almacenar en el array el nombre de la atracción
        atracciones.push(_nombre);
        // Emitir el evento para la nueva atracción
        emit nueva_atraccion(_nombre,_precio);
    }

    // Crear nuevas comida para DISNEY (SOLO es ejecutable por Disney)
    function nuevaComida(string memory _nombre, uint _precio) public unicamente(msg.sender){
        // Creación de una atracción en Disney
        mappingComidas[_nombre] = comida(_nombre,_precio,true);
        // Almacenar en el array el nombre de la atracción
        comidas.push(_nombre);
        // Emitir el evento para la nueva atracción
        emit nueva_comida(_nombre,_precio);
    }

    // Dar de baja a las atracciones en Disney 
    function bajaAtraccion (string memory _nombreAtraccion) public unicamente(msg.sender){
        // El estado de la atraccion pasa a FALSE => No esta en uso 
        mappingAtracciones[_nombreAtraccion].estado_atraccion = false;
        // Emision del evento para la baja de la atraccion 
        emit baja_atraccion(_nombreAtraccion);
    }

    // Dar de baja a las comidas en Disney 
    function bajaComida (string memory _nombreComida) public unicamente(msg.sender){
        // El estado de la comida pasa a FALSE => No esta en uso 
        mappingComidas[_nombreComida].estado_comida = false;
        // Emision del evento para la baja de la comida 
        emit baja_comida(_nombreComida);
    }

    // Visualizar las atracciones de Disney
    function atraccionesDisponibles() public view returns (string[] memory){
        return atracciones;
    }

    // Visualizar las comidas de Disney
    function comidasDisponibles() public view returns (string[] memory){
        return comidas;
    }

    // Función para subirse a una atracción de Disney y pagar en tokens
    function subirAtraccion(string memory _atraccion) public {
        // Precio atraccion (tokens)
        uint tokens_atraccion = mappingAtracciones[_atraccion].precio_atraccion;
        // Verifica el estado de la atraccion (si esta disponible para su uso)
        require(mappingAtracciones[_atraccion].estado_atraccion == true, "La atracción no esta disponible en estos momentos");
        // Verificar el número de tokens que tiene el cliente
        require(tokens_atraccion <= misTokens(), "No tiene tokens suficientes para subir a la atracción.");
        /* El cliente paga la atraccion en Tokens:
        - Ha sido necesario crear una funcion en ERC20.sol con el nombre de: 'transferencia_disney'
        debido a que en caso de usar el Transfer o TransferFrom las direcciones que se escogian 
        para realizar la transccion eran equivocadas. Ya que el msg.sender que recibia el metodo Transfer o
        TransferFrom era la direccion del contrato.
        */
        token.transfer_disney(msg.sender,address(this),tokens_atraccion);
        clientes[msg.sender].token_comprados -= tokens_atraccion;
        // Almancenamiento en el historial de atracciones del cliente
        historialAtracciones[msg.sender].push(_atraccion);
        clientes[msg.sender].atracciones_disfrutadas.push(_atraccion);
        // Emision del evento para disfrutar de la atraccion 
        emit disfruta_atraccion(_atraccion,tokens_atraccion,msg.sender);
    }

    // Función para subirse a una atracción de Disney y pagar en tokens
    function comprarComida(string memory _comida) public {
        // Precio comida (tokens)
        uint tokens_comida = mappingComidas[_comida].precio_comida;
        // Verifica el estado de la comida (si esta disponible para su uso)
        require(mappingComidas[_comida].estado_comida == true, "La comida no esta disponible en estos momentos");
        // Verificar el número de tokens que tiene el cliente
        require(tokens_comida <= misTokens(), "No tiene tokens suficientes para comprar la comida.");
        /* El cliente paga la comida en Tokens:
        - Ha sido necesario crear una funcion en ERC20.sol con el nombre de: 'transferencia_disney'
        debido a que en caso de usar el Transfer o TransferFrom las direcciones que se escogian 
        para realizar la transccion eran equivocadas. Ya que el msg.sender que recibia el metodo Transfer o
        TransferFrom era la direccion del contrato.
        */
        token.transfer_disney(msg.sender,address(this),tokens_comida);
        clientes[msg.sender].token_comprados -= tokens_comida;
        // Almancenamiento en el historial de comidas del cliente
        historialComidas[msg.sender].push(_comida);
        clientes[msg.sender].comidas_disfrutadas.push(_comida);
        // Emision del evento para disfrutar de la comida 
        emit disfruta_comida(_comida,tokens_comida,msg.sender);
    }

    // Visualizar el historial completo de atracciones disfrutadas por un cliente
    function historialAtraccion() public view returns (string [] memory){
        return historialAtracciones[msg.sender];
    }

    // Visualizar el historial completo de comidas disfrutadas por un cliente
    function historialComida() public view returns (string [] memory){
        return historialComidas[msg.sender];
    }

    // Función para que un cliente de Disney pueda devolver tokens
    function devolverTokens(uint _tokens) public payable{
        require(_tokens > 0, "Necesitas devolver una cantidad positiva de tokens");
        require(_tokens <= misTokens(), "No tienes los tokens que deseas devolver");
        token.transfer_disney(msg.sender, address(this),_tokens);
        msg.sender.transfer(precioToken(_tokens));
        
    }



}