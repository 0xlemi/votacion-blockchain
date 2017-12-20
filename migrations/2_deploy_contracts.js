var Votacion = artifacts.require("./Votacion.sol");

module.exports = function(deployer) {
    // Migrando el contracto votacion
    deployer.deploy(Votacion, 1000, web3.toWei('0.1', 'ether'), ['Peje', 'Meade', 'Anaya']);
    /* la funcion "toWei" convierte la canditdad de ether a weis
     * Porque es le valor minimo que maneja etherium y es le valor que se usa para las operaciones
     * Esta es la tabla de le valor de differentes unidades en Etherium
     *       'wei':          '1',
     *       'kwei':         '1000',
     *       'mwei':         '1000000',
     *       'gwei':         '1000000000',
     *       'szabo':        '1000000000000',
     *       'milliether':   '1000000000000000',
     *       'ether':        '1000000000000000000',
     *       'kether':       '1000000000000000000000',
     *       'mether':       '1000000000000000000000000',
     *       'gether':       '1000000000000000000000000000',
     *       'tether':       '1000000000000000000000000000000'
    */
};
