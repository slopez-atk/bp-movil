import React from 'react';
import {BootstrapTable, TableHeaderColumn} from 'react-bootstrap-table';

class PercentIndicadoresTable extends React.Component{
  constructor(props){
    super(props);
    this.calculoDePorcentajeCantidad = this.calculoDePorcentajeCantidad.bind(this);
    this.calculoDePorcentajeCapActivo = this.calculoDePorcentajeCapActivo.bind(this);
    this.calculoDePorcentajeCapNDevenga = this.calculoDePorcentajeCapNDevenga.bind(this);
    this.calculoDePorcentajeCarteraRiesgo = this.calculoDePorcentajeCarteraRiesgo.bind(this);
    this.calculoDePorcentajeCapVencido = this.calculoDePorcentajeCapVencido.bind(this);
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
    console.log(this.props.cantidad)
    let cantidad = ((parseFloat(cell)*100)/parseFloat(this.props.cantidad)).toFixed(2);
    return(
      <td>{cantidad}%</td>
    );
  }

  calculoDePorcentajeCapActivo(cell, row){
    let cantidad = ((parseFloat(cell)*100)/parseFloat(this.props.cap_activo)).toFixed(2);
    return(
      <td>{cantidad}%</td>
    );
  }

  calculoDePorcentajeCapNDevenga(cell, row){
    let cantidad = ((parseFloat(cell)*100)/parseFloat(this.props.cap_ndevenga)).toFixed(2);
    return(
      <td>{cantidad}%</td>
    );
  }

  calculoDePorcentajeCarteraRiesgo(cell, row){
    let cantidad = ((parseFloat(cell)*100)/parseFloat(this.props.cartera_riesgo)).toFixed(2);
    return(
      <td>{cantidad}%</td>
    );
  }

  calculoDePorcentajeCapVencido(cell, row){
    let cantidad = ((parseFloat(cell)*100)/parseFloat(this.props.cap_vencido)).toFixed(2);
    return(
      <td>{cantidad}%</td>
    );
  }

  componentWillMount(){
    this.calcularSumatorias();
  }

  calcularSumatorias(){
    let data = this.props.data_percent;
    let suma_cantidad = 0;
    let suma_cap_activo = 0;
    let suma_cap_ndevenga = 0;
    let suma_cartera_riesgo = 0;
    let suma_cap_vencido = 0;
    for(let i=0; i<data.length; i++){
      suma_cantidad += parseFloat(data[i]["cantidad"]);
      suma_cap_activo += parseFloat(data[i]["cap_activo"]);
      suma_cap_ndevenga += parseFloat(data[i]["cap_ndevenga"]);
      suma_cartera_riesgo += parseFloat(data[i]["cartera_riesgo"]);
      suma_cap_vencido += parseFloat(data[i]["cap_vencido"]);

    }
    let totales = {clave: 'Total', cantidad: suma_cantidad, cap_activo: suma_cap_activo.toFixed(2) ,cap_ndevenga: suma_cap_ndevenga.toFixed(2), cartera_riesgo: suma_cartera_riesgo.toFixed(2), cap_vencido: suma_cap_vencido.toFixed(2)};
    data.push(totales);
  }



  render(){
    const options = {
      toolBar: this.createCustomToolBar
    };
    let data = this.props.data_percent.pop();
    return(
      <div>
        <h4 className="top-space" style={{color: "#FFC107"}}>{ this.props.title }</h4>
        <div>
          <BootstrapTable ref='table' data={ this.props.data_percent } exportCSV={ true } hover options={options}>
            <TableHeaderColumn dataField='clave' isKey={ true } dataSort={ true } width='250'>Indicador</TableHeaderColumn>
            <TableHeaderColumn dataField='cantidad' dataSort={ true } width='250' dataFormat={this.calculoDePorcentajeCantidad}>% Cantidad</TableHeaderColumn>
            <TableHeaderColumn dataField='cap_activo' dataSort={ true } width='250' dataFormat={this.calculoDePorcentajeCapActivo}>% Capital Activo</TableHeaderColumn>
            <TableHeaderColumn dataField='cap_ndevenga' dataSort={ true } width='250' dataFormat={this.calculoDePorcentajeCapNDevenga}>% Capital no Devenga</TableHeaderColumn>
            <TableHeaderColumn dataField='cartera_riesgo' dataSort={ true } width='250' dataFormat={this.calculoDePorcentajeCarteraRiesgo}>% Cartera Riesgo</TableHeaderColumn>
            <TableHeaderColumn dataField='cap_vencido' dataSort={ true } width='250' dataFormat={this.calculoDePorcentajeCapVencido}>% Capital Vencido</TableHeaderColumn>
          </BootstrapTable>
        </div>
      </div>
    );
  }
}



export default PercentIndicadoresTable;