import React from 'react';
import {BootstrapTable, TableHeaderColumn} from 'react-bootstrap-table';

class PercentIndicadoresColocadosTable extends React.Component{
  constructor(props){
    super(props);
    this.calculoDePorcentajeCantidad = this.calculoDePorcentajeCantidad.bind(this);
    this.calculoDePorcentajeMontoReal = this.calculoDePorcentajeMontoReal.bind(this);
  }

  createCustomToolBar = props => {
    return (
      <div style={ { margin: '15px' } }>
        { props.components.btnGroup }
        <div className='col-xs-8 col-sm-4 col-md-4 col-lg-2'>
          { props.components.searchPanel }
        </div>
      </div>
    );
  };

  calculoDePorcentajeCantidad(cell, row){
    let cantidad = ((parseFloat(cell)*100)/parseFloat(this.props.cantidad)).toFixed(2);
    return(
      <td>{cantidad}%</td>
    );
  }

  calculoDePorcentajeMontoReal(cell, row){
    let cantidad = ((parseFloat(cell)*100)/parseFloat(this.props.monto_real)).toFixed(2);
    return(
      <td>{cantidad}%</td>
    );
  }



  componentWillMount(){
    this.calcularSumatorias();
  }

  calcularSumatorias(){
    let data = this.props.data;
    let suma_cantidad = 0;
    let suma_monto_real = 0;
    for(let i=0; i<data.length; i++){
      suma_cantidad += parseFloat(data[i]["cantidad"]);
      suma_monto_real += parseFloat(data[i]["monto_real"]);

    }
    let totales = {clave: 'Total', cantidad: suma_cantidad, monto_real: suma_monto_real.toFixed(2)};
    data.push(totales);
  }



  render(){
    const options = {
      toolBar: this.createCustomToolBar
    };
    return(
      <div>
        <h4 className="top-space" style={{color: "#FFC107"}}>{ this.props.title }</h4>
        <div>
          <BootstrapTable ref='table' data={ this.props.data } exportCSV={ true } hover options={options}>
            <TableHeaderColumn dataField='clave' isKey={ true } dataSort={ true } width='250'>Indicador</TableHeaderColumn>
            <TableHeaderColumn dataField='cantidad' dataSort={ true } width='250' dataFormat={this.calculoDePorcentajeCantidad}>% Cantidad</TableHeaderColumn>
            <TableHeaderColumn dataField='monto_real' dataSort={ true } width='250' dataFormat={this.calculoDePorcentajeMontoReal}>% Monto Real</TableHeaderColumn>
          </BootstrapTable>
        </div>
      </div>
    );
  }
}

export default PercentIndicadoresColocadosTable;