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
