import React from 'react';


class TableDates extends React.Component{

  constructor(props){
    super(props);
  }

  getHead(){
    return this.props.ArrayDates.map(date => {
      return <th key={date}>{date}</th>
    })
  }

  getSaldos(){
    // Para sumar el saldo de una fecha
    let saldo = 0;
    let cantidad = 0;
    let provision = 0;
    let valor_recuperado = 0;

    // Recupero el array de datos junto con el array que tiene las fechas entre semana
    let data = this.props.DataWeek;
    let dates = this.props.ArrayDates;

    // Arrays para ir guardando la sumatoria de saldos del dia y la cantidad por dia
    let saldos = [];
    let cantidades = [];
    let provisiones = [];
    let valores_recuperados = [];

    for(let i=0; i<dates.length; i++){
      saldo = 0;
      cantidad = 0;
      provision = 0;
      for(let j=0; j<data[dates[i]].length; j++){
        saldo += parseFloat(data[dates[i]][j]['saldo']);
        provision += parseFloat(data[dates[i]][j]['provision']);
        valor_recuperado += parseFloat(data[dates[i]][j]['valor_recuperado']);
        cantidad ++;
      }
      saldos.push(saldo.toFixed(2));
      cantidades.push(cantidad);
      provisiones.push(provision.toFixed(2));
      valores_recuperados.push(valor_recuperado.toFixed(2));
    }
    return [saldos, cantidades,provisiones, valores_recuperados];
  }

  getBody(saldos){
    return saldos.map((row, index) => {
      return <td key={ index }>{ row }</td>
    })
  }


  render(){
    let datos = this.getSaldos();
    return(
      <div>
        <div className="table-responsive">
          <table className="table table-striped table-hover">
            <thead>
              <tr>
                <th>Detalles</th>
                { this.getHead() }
              </tr>
            </thead>
            <tbody>
              <tr>
                <th>Saldos</th>
                { this.getBody(datos[0]) }
              </tr>
              <tr>
                <th>Cantidades</th>
                { this.getBody(datos[1]) }
              </tr>
              <tr>
                <th>Provisiones</th>
                { this.getBody(datos[2]) }
              </tr>
              <tr>
                <th>Valor Recuperado</th>
                { this.getBody(datos[3]) }
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    );
  }
}

export default TableDates;