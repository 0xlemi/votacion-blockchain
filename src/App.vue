<template lang="html">
<div id="app">
    <div class="container">
        <br>
        <!-- INICIO titulo -->
        <div class="header clearfix">
            <h3 class="text-muted">Sistema de Votacion Mexico</h3>
        </div>
        <!-- FIN titulo -->

        <!-- INICIO jumbotron -->
        <div class="jumbotron">
            <h1 class="display-3">Tu voto vale.</h1>
            <p class="lead">
                Este es un sistema de votacion.
                Usando tecnologia de blockchain para no confiar la vericidad
                de los votos a un tercero.
            </p>
        </div>
        <!-- FIN jumbotron -->

        <!-- INICIO tabla de los candidatos -->
        <div class="row">
            <b-table bordered hover :items="candidatos"></b-table>
        </div>
        <!-- FIN tabla de los candidatos -->

        <!-- INICIO seleccion y voto por los candidatos -->
        <div class="row">
            <div class="col-md-12">
                <b-card title="Votar por Candidato">
                    <br>
                    <div class="row">
                        <div class="col-md-6">
                            <b-form-select v-model="candidatoSeleccionado"
                                            :options="seleccionCandidatos" class="mb-3">
                            </b-form-select>
                        </div>
                        <div class="col-md-6">
                            <b-input-group>
                                <b-form-input v-model="tokensVotar" placeholder="Numero de Votos"
                                                type="number" min="0">
                                </b-form-input>
                                <b-input-group-button>
                                    <b-btn variant="primary" @click="votar">Votar</b-btn>
                                </b-input-group-button>
                            </b-input-group>
                        </div>
                    </div>
                </b-card>
            </div>
        </div>
        <!-- FIN seleccion y voto por los candidatos -->

        <!-- INICIO tabla tokens info y comprar votos -->
        <div class="row marketing">
            <div class="col-md-6">
                <h4>Tokens de votacion</h4>
                <br>
                <b-table bordered hover :items="tokens"></b-table>
            </div>
            <div class="col-md-6">
                <br>
                <br>
                <b-card title="Comprar Votos">
                    <p class="card-text">
                        Nunca dijimos que este sistema de votacion seria democratico.
                        Los votos se compran.
                    </p>
                    <b-input-group>
                        <b-form-input v-model="votosComprar" type="number" min="0"></b-form-input>
                        <b-input-group-button>
                            <b-btn variant="success" @click="comprar">Comprar</b-btn>
                        </b-input-group-button>
                    </b-input-group>
                    <br>
                    <div class="form-group row">
                        <label class="col-sm-6 col-form-label">Votos que Poseo: </label>
                        <div class="col-sm-6">
                            <input type="text" v-model="votosDelUsuario" class="form-control" readonly>
                        </div>
                    </div>
                </b-card>
            </div>
        </div>
        <!-- FIN tabla tokens info y comprar votos -->

        <!-- INICIO informacion sobre otros votantes     -->
        <div class="row marketing">
            <div class="col-md-12">
                <b-card title="Informacion sobre otros votantes">
                    <br>
                    <b-input-group>
                        <b-form-input v-model="codigoVotanteABuscar" type="text"
                                        placeholder="Address Publico" min="0">
                        </b-form-input>
                        <b-input-group-button>
                            <b-btn variant="success" @click="obtenerDetalles">Buscar</b-btn>
                        </b-input-group-button>
                    </b-input-group>
                    <br>
                    <div v-if="encontroInfo">
                        <div class="form-group row">
                            <label class="col-sm-6 col-form-label">Votos sin utilizar: </label>
                            <div class="col-sm-6">
                                <input type="text" v-model="votosDelUsuarioEnDetalle"
                                        class="form-control" readonly>
                            </div>
                        </div>
                        <br>
                        <b-table bordered hover :items="detallesCandidatos"></b-table>
                    </div>
                    <div v-else>
                        <br>
                        <b-alert variant="warning" show>Address No Encontrado</b-alert>
                    </div>
                </b-card>
            </div>
        </div>
        <!-- FIN informacion sobre otros votantes     -->

    </div>
</div>
</template>

<script>
// Importar librerias
import { default as Web3 } from 'web3';
import { default as contract } from 'truffle-contract';

import contracto_votacion from '../build/contracts/Votacion.json';


export default {
    name: 'app',
    data() {
        return {

            candidatoSeleccionado: null, // Numero Unitario del candidato seleccionado en el select
            votosComprar: null,
            tokensVotar: null,
            encontroInfo: false, // Si buscar informacion sobre otros vatantes fue exitoso

            votosDelUsuario: null, // Cuantos votos le quedan sin utilizar al usario en cuestion
            votosDelUsuarioEnDetalle: null, // Cuantos votos le quedan sin utilizar al
                                            // votante que el usuario busco.

            codigoVotanteABuscar: null, // El address del votante que quieres buscar.

            seleccionCandidatos: [
                { value: null, text: 'Selecciona tu candidato' },
                { value: null, text: null },
                { value: null, text: null },
                { value: null, text: null },
            ],
            candidatos: [
                { nombre: null, votos: null },
                { nombre: null, votos: null },
                { nombre: null, votos: null }
            ],
            detallesCandidatos:[
                { nombre: null, votos: null },
                { nombre: null, votos: null },
                { nombre: null, votos: null },
            ],
            tokens: [
                { informacion: 'Total Votos Posibles', valor: null },
                { informacion: 'Total Votos Disponibles', valor: null },
                { informacion: 'Total Votos Vendidos', valor: null },
                { informacion: 'Precio Por Voto', valor: null },
                { informacion: 'Total Dinero Recolectado', valor: null }
            ],
        }
    },
    methods: {
        votar(){
            let vue = this;
            this.votacion.deployed().then(function(contractInstance) {
                contractInstance.votarPorCandidato(vue.candidatoSeleccionado,
                        parseInt(vue.tokensVotar), {gas: 140000, from: web3.eth.accounts[0]}).then(function() {

                    let votosAnteriores = parseInt(vue.candidatos[vue.candidatoSeleccionado].votos);
                    let votosRecienUsados = parseInt(vue.tokensVotar);
                    // Actualizar la tabla de los candidatos
                    vue.candidatos[vue.candidatoSeleccionado].votos = votosAnteriores + votosRecienUsados;
                    // Actualizar votos que poseo
                    vue.votosDelUsuario -= parseInt(vue.tokensVotar);
                    // Resetear el text donde pones los votos que quieres utilizar
                    vue.tokensVotar = "";
                });
            });
        },
        comprar(){
            let vue = this;
            this.votacion.deployed().then(function(contractInstance) {
                let contrato = contractInstance;
                let precio = vue.votosComprar * vue.precioPorVoto;
                // Llamar la funcion comprar
                contrato.comprar({value: web3.toWei(precio, 'ether'), from: web3.eth.accounts[0]}).then(function(){
                    // Actualizar Total Votos Disponibles
                    vue.tokens[1].valor = parseInt(vue.tokens[1].valor) - parseInt(vue.votosComprar);
                    // Actualizar Total Votos Vendidos
                    vue.tokens[2].valor = parseInt(vue.tokens[2].valor) + parseInt(vue.votosComprar);
                    // Actualizar Total Dinero Recolectado
                    web3.eth.getBalance(contrato.address, function(error, result){
                        let balance = web3.fromWei(result.toString());
                        vue.tokens[4].valor = balance + " Ether";
                    });

                    // Actualizar el total de votos que le quadan sin utilizar al usuario
                    vue.votosDelUsuario += parseInt(vue.votosComprar);
                    vue.votosComprar = "";
                })
            });
        },
        agregarCandidatos() {
            let vue = this;
            this.votacion.deployed().then(function(contractInstance) {
                let contrato = contractInstance;
                /* Llamamos la funcion todosLosCandidatos que nos regresa un array
                 * con los nombres de los candidatos.
                 */
                contrato.todosLosCandidatos.call().then(function(candidateArray) {
                    for(let i=0; i < candidateArray.length; i++){
                        /* Los nombres de los candidatos estan en bytes32 en el blockchain.
                         * Lo tenemos que convertir a string para poderlo utilizar
                         * Para esto usamos la funcion toUtf8
                         */
                        let nombre = web3.toUtf8(candidateArray[i]);
                        vue.candidatos[i].nombre = nombre;
                        vue.detallesCandidatos[i].nombre = nombre;
                        /* Llamar la funcion totalVotosPor para tambien
                         * guardar la cantidad de votos
                         */
                        contrato.totalVotosPor.call(i).then(function(votos) {
                            vue.candidatos[i].votos = votos;
                        });

                        // Tambien llenar le select de candidatos
                        vue.seleccionCandidatos[i+1].text = nombre;
                        vue.seleccionCandidatos[i+1].value = i;
                    }
                });
            });
        },
        agregarInfoTokens(){
            let vue = this;
            this.votacion.deployed().then(function(contractInstance){
                contractInstance.totalDeVotos.call().then(function(v) {
                    vue.tokens[0].valor = v.toString();
                });
                contractInstance.votosRestantes.call().then(function(v) {
                    vue.tokens[1].valor = v.toString();
                });
                contractInstance.votosVendidos.call().then(function(v) {
                    vue.tokens[2].valor = v.toString();
                });
                contractInstance.precioToken.call().then(function(v) {
                    vue.precioPorVoto = parseFloat(web3.fromWei(v.toString()));
                    vue.tokens[3].valor = vue.precioPorVoto + " Ether";
                });
                web3.eth.getBalance(contractInstance.address, function(error, result) {
                    let balance = web3.fromWei(result.toString());
                    vue.tokens[4].valor = balance + " Ether";
                });
            });
        },
        obtenerDetalles() {
            let vue = this;
            this.votacion.deployed().then(function(contractInstance) {
                contractInstance.detallesVotante.call(vue.codigoVotanteABuscar).then(function(result) {
                    try {
                        /* Llena la tabla con los candidatos por los cuales voto,
                         * el votante de ese address.
                         */
                        for(let i=0; i < vue.detallesCandidatos.length; i++) {
                            vue.detallesCandidatos[i].votos = result[0][i].c[0];
                        }
                        // Votos que le quedan a el votante de ese address
                        vue.votosDelUsuarioEnDetalle = parseInt(result[1]);
                        vue.encontroInfo = true;
                    }catch(err){
                        // Registra el error en la variable 'encontroInfo' para mostrar el alert
                        vue.encontroInfo = false;
                        console.error(err);
                    }
                });
            });
        },
        votosDelUsuarioActual(){
            let vue = this;
            this.votacion.deployed().then(function(contractInstance) {
                // Llamar la funcion 'detallesDelVotante' con el address del votante actual
                contractInstance.detallesVotante.call(web3.eth.accounts[0]).then(function(result) {
                    // Actualizar la variable de votos restantes
                    vue.votosDelUsuario = parseInt(result[1]);
                });
            });
        },
    },
    mounted(){
        // Aqui es donde instanciamos el contrato de votacion
        this.votacion = contract(contracto_votacion);
        if(typeof web3 !== 'undefined'){
            console.warn("Web3 detectado, se esta utilizando Metamask");
            // Como si se esta usando el provedor Mist/MetaMask
            window.web3 = new Web3(web3.currentProvider);
        } else {
            console.warn("No detectamos web3. Favor de usar chrome e installar MetaMask");
            alert("No detectamos web3. Favor de usar chrome e installar MetaMask");
        }
        // Ligamos votacion con el provedor
        this.votacion.setProvider(web3.currentProvider);
        // Llenar la table de los candidatos y el select
        this.agregarCandidatos();
        // Llenar la tabla con 'Tokens de Votacion' con la informacion
        this.agregarInfoTokens();
        // Obtener 'votosDelUsuario'
        this.votosDelUsuarioActual();
    }
}
</script>

<style lang="css" scoped>
/* Space out content a bit */
body {
  padding-top: 1.5rem;
  padding-bottom: 1.5rem;
}

/* Everything but the jumbotron gets side spacing for mobile first views */
.header,
.marketing,
.footer {
  padding-right: 1rem;
  padding-left: 1rem;
}

/* Custom page header */
.header {
  padding-bottom: 1rem;
  border-bottom: .05rem solid #e5e5e5;
}

/* Make the masthead heading the same height as the navigation */
.header h3 {
  margin-top: 0;
  margin-bottom: 0;
  line-height: 3rem;
}

/* Custom page footer */
.footer {
  padding-top: 1.5rem;
  color: #777;
  border-top: .05rem solid #e5e5e5;
}

/* Customize container */
@media (min-width: 48em) {
  .container {
    max-width: 46rem;
  }
}
.container-narrow > hr {
  margin: 2rem 0;
}

/* Main marketing message and sign up button */
.jumbotron {
  text-align: center;
  border-bottom: .05rem solid #e5e5e5;
}
.jumbotron .btn {
  padding: .75rem 1.5rem;
  font-size: 1.5rem;
}

/* Supporting marketing content */
.marketing {
  margin: 3rem 0;
}
.marketing p + h4 {
  margin-top: 1.5rem;
}

/* Responsive: Portrait tablets and up */
@media screen and (min-width: 48em) {
  /* Remove the padding we set earlier */
  .header,
  .marketing,
  .footer {
    padding-right: 0;
    padding-left: 0;
  }

  /* Space out the masthead */
  .header {
    margin-bottom: 2rem;
  }

  /* Remove the bottom border on the jumbotron for visual effect */
  .jumbotron {
    border-bottom: 0;
  }
}
</style>
