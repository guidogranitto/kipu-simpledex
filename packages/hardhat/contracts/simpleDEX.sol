// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleDEX {
    IERC20 public tokenA; // Interfaz del token A (ERC-20)
    IERC20 public tokenB; // Interfaz del token B (ERC-20)
    address public owner; // Dirección del creador del contrato

    uint256 public reserveA; // Almacenan stock de token A
    uint256 public reserveB; // Almacenan stock de token B

    // Eventos
    event LiquidityAdded(address provider, uint256 amountA, uint256 amountB);
    event TokensSwapped(
        address swapper,
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount
    );
    event LiquidityRemoved(address provider, uint256 amountA, uint256 amountB);

    // Constructor: Recibe las direcciones de los tokens que forman parte del pool
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    // Modificador (Restringir funciones a usuarios para que no puedan dar o quitar liquidez)
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Solo el propietario puede ejecutar esta funcion"
        );
        _;
    }

    // (1) Función para agregar liquidez --------------------------------------- /
    // Importante: asegurarse que las cantidades sean mayores a 0
    function addLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        require(amountA > 0 && amountB > 0, "La suma debe ser mayor a 0");

        tokenA.transferFrom(msg.sender, address(this), amountA); // transferFrom envia tokens de la cuenta del propietario a la direccion del contrato
        tokenB.transferFrom(msg.sender, address(this), amountB);

        reserveA += amountA; // cantidad actual de TokenA almacenada en el pool del contrato  => las mismas se actualizan sumando las cantidades recién añadidas
        reserveB += amountB; // cantidad actual de TokenB almacenada en el pool del contrato  => las mismas se actualizan sumando las cantidades recién añadidas

        emit LiquidityAdded(msg.sender, amountA, amountB); // se informa las cantidades de liquidez añadidas
    }

    // (2) Función intercambio de A por B (swap AxB) ---------------------- /
    // Importante: asegurarse que las cantidades establecidas sean mayores a 0
    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "La suma debe ser mayor a 0");

        uint256 amountBOut = getSwapAmount(amountAIn, reserveA, reserveB); // formula del producto constante
        require(
            amountBOut > 0,
            "Fondos insuficientes para completar el intercambio"
        ); // verifica que el usuario pueda recibir una cantidad de TokenB mayor a 0.

        tokenA.transferFrom(msg.sender, address(this), amountAIn); // cantidad de TokenA | direccion usuario | transfencia al contrato
        tokenB.transfer(msg.sender, amountBOut); // cantidad de TokenB que el usuario debe recibir |

        reserveA += amountAIn; // incrementa la cantidad de TokenA en el pool
        reserveB -= amountBOut; // Reduce la cantidad de TokenB en el pool

        emit TokensSwapped(
            msg.sender,
            address(tokenA),
            address(tokenB),
            amountAIn,
            amountBOut
        ); // se informa el intercambio realizado (swap completed)
    }

    // (3) Función intercambio de B por A --------------------------------------- /
    // Importante: asegurarse que las cantidades establecidas sean mayores a 0
    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "La suma debe ser mayor a 0");

        uint256 amountAOut = getSwapAmount(amountBIn, reserveB, reserveA); // formula del producto constante
        require(
            amountAOut > 0,
            "Fondos insuficientes para completar el intercambio"
        ); // verifica que el usuario pueda recibir una cantidad de TokenB mayor a 0.

        tokenB.transferFrom(msg.sender, address(this), amountBIn); // cantidad de TokenB | direccion usuario | transfencia al contrato
        tokenA.transfer(msg.sender, amountAOut); // cantidad de TokenB que el usuario debe recibir

        reserveB += amountBIn; // incrementa la cantidad de TokenB en el pool
        reserveA -= amountAOut; // Reduce la cantidad de TokenA en el pool

        emit TokensSwapped(
            msg.sender,
            address(tokenB),
            address(tokenA),
            amountBIn,
            amountAOut
        ); // se informa el intercambio realizado (swap completed)
    }

    // (4) Función quitar liquidez ------------------------------------------------ /
    // Importante: asegurarse que las cantidades sean mayores a 0
    // Importante: comprueba que haya saldo en reserva para realizar la operacion
    function removeLiquidity(
        uint256 amountA,
        uint256 amountB
    ) external onlyOwner {
        // establecer cantidades de tokens a retirar.
        require(amountA > 0 && amountB > 0, "La suma debe ser mayor a 0");
        require(
            amountA <= reserveA && amountB <= reserveB,
            "Saldo insuficiente"
        );

        tokenA.transfer(msg.sender, amountA); // transferencia de tokensA desde el contrato hacia el usuario
        tokenB.transfer(msg.sender, amountB); // transferencia de tokensB desde el contrato hacia el usuario

        reserveA -= amountA; // cantidad actual de TokenA almacenada en el pool del contrato => las mismas se actualizan restando las cantidades sustraidas
        reserveB -= amountB; // cantidad actual de TokenB almacenada en el pool del contrato => las mismas se actualizan restando las cantidades sustraidas

        emit LiquidityRemoved(msg.sender, amountA, amountB); // se informa la liquidez removida
    }

    // (5) Función obtener precio -------------------------------------------------------------------- /
    // consultar el precio de un token con respecto al otro
    function getPrice(address _token) external view returns (uint256) {
        require(
            _token == address(tokenA) || _token == address(tokenB),
            "Direccion de token invalida"
        ); // verificar tokens

        // calculo del precio de los tokens
        if (_token == address(tokenA)) {
            return (reserveB * 1e18) / reserveA; // Devuelve precio de 1 TokenA con respecto al TokenB
        } else {
            return (reserveA * 1e18) / reserveB; // Devuelve precio de 1 TokenB con respecto al TokenA
        }
    }

    // (6) Función obtener suma del intercambio ------------------------------------------------------------------------------- /
    // cantidad de tokens de salida que el usuario recibe al realizar un intercambio
    function getSwapAmount(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) internal pure returns (uint256) {
        // es pure porque no modifica el estado del contrato.
        uint256 inputAmountWithFee = inputAmount * 997; // comision del 0.3% sobre la cantidad de tokens de entrada
        uint256 numerator = inputAmountWithFee * outputReserve; // numerador = tokens de salida disponibles para el usuario * tokens de entrada con la comisión aplicada
        uint256 denominator = (inputReserve * 1000) + inputAmountWithFee; // total de tokens de reserva del pool *  cantidad de token que ingresa al pool + cantidad de tokens que el usuario desea intercambiar .denominator = relación entre las reservas del pool y los tokens que se intercambian.
        return numerator / denominator; // cantidad de tokens que recibe el usuario (ajusta el precio del intercambio)
    }
}
