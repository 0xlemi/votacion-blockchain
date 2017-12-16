pragma solidity ^0.4.10; // Tenemos que espesificar que version del compilador queremos utilizar

contract Votacion {

    // Usamos tipo de variable 'struct' que es un objecto.
    // Y guardamos ally toda la informacion
    struct votante {
        address codigoVotante; // El address que identifica al votante en el blockchain
        uint votosComprados; // Numero total de votos que este votante a comprado
        uint[] votosUsadosPorCandidato; // Un array para ver en que candidatos a usado sus votos
    }

    // Guardamos los votantes en el array asociativa
    mapping (address => votante) public infoVotante;

    // Mantenemos la cuenta de los votos por candidato en otra array asociativa
    mapping (uint => uint) public votosRecibidos;

    /*  Solidity no te deja tener arrays de strings tenemos que utilizar bytes32
        Lista de todos los candidatos por los que se puede votar
        Los indices de esto array coinciden con los indices de votosRecibidos
    */
    bytes32[] public listaCandidatos;

    uint public totalDeVotos; // Num. Total de votos disponibles para la eleccion
    uint public votosRestantes; // Num. Total de votos que quedan para comprar
    uint public precioToken; // Precio por token


    /*  Cuando es contracto se instancie en el blockchain, vamos a inicializar
        el numero total de votos a la venta, consto por token y los candidatos.
    */
    function Votacion(uint totalVotos, uint precio, bytes32[] candidatos){
        listaCandidatos = candidatos;
        totalDeVotos = totalVotos;
        votosRestantes = totalVotos;
        precioToken = precio;
    }

    /* Numero de votos que tiene cada candidato
    */
    function totalVotosPor(uint indexDelCandidato) constant returns (uint)
    {
        return votosRecibidos[indexDelCandidato];
    }

    function votarPorCandidato(uint indexDelCandidato, uint votosEjercer)
    {
        // Asegurando que no manden indices incorrectos
        if(indexDelCandidato == uint(-1)) throw;

        /*  Nota: "msg.sender" la direccion publica del votante
            que esta tratando de llamar la function
        */

        /*  Si esta el la primera ves que le votante vota
            votosUsadosPorCandidato va a estar vacia
            la nececitamos llenar con zeros. Andes que nada.
        */
        if(infoVotante[msg.sender].votosUsadosPorCandidato.length == 0)
        {
            for(uint i = 0; i < listaCandidatos.length; i++){
                infoVotante[msg.sender].votosUsadosPorCandidato.push(0);
            }
        }

        // Asegurate que le votante tenga los votos que quiere registrar
        uint votosUtilizados = totalVotosUtilizados(infoVotante[msg.sender].votosUsadosPorCandidato);
        uint votosEnPosesion = infoVotante[msg.sender].votosComprados - votosUtilizados;
        if(votosEnPosesion < votosEjercer) throw;

        // Registrar los votos
        votosRecibidos[indexDelCandidato] += votosEjercer;

        // Guardar registro de cuantos votos el votante ha hecho para este candidato
        infoVotante[msg.sender].votosUsadosPorCandidato[indexDelCandidato] += votosEjercer;
    }

    // Esta funcion solo suma los votos en _votosUsadosPorCandidato array
    function totalVotosUtilizados(uint[] _votosUsadosPorCandidato) private constant returns (uint)
    {
        uint totalVotosUtilizadosVar = 0;
        // Recorre uno por uno sumandolos
        for(uint i = 0; i < _votosUsadosPorCandidato.length; i++){
            totalVotosUtilizadosVar += _votosUsadosPorCandidato[i];
        }
        return totalVotosUtilizadosVar;
    }

    /*  Esta funcion el la que permite comprar los votos. Nota la palabra 'payable'.
        Solo agregando esta palabra, la funcion puede aceptar Ether de cualquera que la llame.
        Acceptar dinero nunca fue tan facil !!!
    */
    function comprar() payable returns (uint)
    {
        /*  La variable 'msg.value' es la cantidad de ether que estan pagando.
            Se necesita dividir la cantidad entre el precio para obtener el
            numero de votos que estan comprando.
        */
        uint votosAComprar = msg.value / precioToken;
        if(votosAComprar > votosRestantes) throw;

        infoVotante[msg.sender].codigoVotante = msg.sender;
        infoVotante[msg.sender].votosComprados += votosAComprar;

        // Remover los votos de los votosRestantes
        votosRestantes -= votosAComprar;

        return votosAComprar;
    }

    // Total de los votos ya vendidos
    function votosVendidos() constant returns (uint)
    {
        return totalDeVotos - votosRestantes;
    }

    /**
     *  Obtener la informacion del votante
     * param adress     voter public address
     * return array     array con 2 elementos:
                            1) Array con los votos ue el votante ha hecho por cada candidato.
                            2) Numero de votos que tiene sin utilizar.
    */
    function detallesVotante(address codigoVotante) constant returns (uint[], uint)
    {
        uint votosUtilizados = totalVotosUtilizados(infoVotante[codigoVotante].votosUsadosPorCandidato);
        uint votosNoUsados = infoVotante[codigoVotante].votosComprados - votosUtilizados;
        return (infoVotante[codigoVotante].votosUsadosPorCandidato, votosNoUsados);
    }

    /* Un getter para listaCandidatos
    */
    function todosLosCandidatos() constant returns (bytes32[])
    {
        return listaCandidatos;
    }

    /*  Esta funcion es para dereminar a donde se va el Ether pagado.
        Todo el Ether eviado pol los votantes que copraron se guarda en esta cuanta automaticamente.
        *** Nota: la forma en la que esta funcion esta escrita cualquera puede llamarla y trasmitir
        el Ether a sup propia cuenta. En un app verdadera deves de agregar una verificacion para
        asegural que solo el dueno tenga accesso el Ether.
    */
    function transferTo(address account)
    {
        account.transfer(this.balance);
    }

}
