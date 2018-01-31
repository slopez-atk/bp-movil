import React from 'react';
import {BootstrapTable, TableHeaderColumn} from 'react-bootstrap-table';
import Paper from 'material-ui/Paper';
import RaiseButton from 'material-ui/RaisedButton';

class ReporteAgencias extends React.Component{
  constructor(props){
    super(props);
    this.buttonAction = this.buttonAction.bind(this);
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

  CalculoMora(cell, row){
    let mora = ((parseFloat(row.cartera_afectada)*100)/parseFloat(row.saldo_cartera)).toFixed(2);
    return(
      <td>{mora}%</td>
    );
  }

  buttonAction(cell, row){
    return(
      <RaiseButton primary label="Ver" onClick={()=>  this.props.onClick(row.sucursales) }/>
    );
  }

  calcularSumatorias(){
    let data = this.props.data;
    let suma_cap_activo = 0;
    let suma_cap_ndevenga = 0;
    let suma_cap_vencido = 0;
    let suma_cartera_afectada = 0;
    let suma_saldo_cartera = 0;
    let suma_num_creditos = 0;
    let suma_monto_credito = 0;
    for(let i=0; i<data.length; i++){
      suma_cap_activo += parseFloat(data[i]["cap_activo"]);
      suma_cap_ndevenga += parseFloat(data[i]["cap_ndevenga"]);
      suma_cap_vencido += parseFloat(data[i]["cap_vencido"]);
      suma_cartera_afectada += parseFloat(data[i]["cartera_afectada"]);
      suma_saldo_cartera += parseFloat(data[i]["saldo_cartera"]);
      suma_num_creditos += data[i]["num_creditos"];
      suma_monto_credito += parseFloat(data[i]["monto_credito"]);
    }
    let totales = {sucursales: 'Total', num_creditos: suma_num_creditos, monto_credito: suma_monto_credito, cap_activo: suma_cap_activo.toFixed(2), cap_ndevenga: suma_cap_ndevenga.toFixed(2), cap_vencido:suma_cap_vencido.toFixed(2), cartera_afectada:suma_cartera_afectada.toFixed(2), saldo_cartera:suma_saldo_cartera.toFixed(2)}
    data.push(totales);
  }

  componentWillMount(){
    this.calcularSumatorias();
  }


  render(){
    const options = {
      toolBar: this.createCustomToolBar
    };
    return(
      <Paper zDepth={2} className="top-space padding">

        <BootstrapTable ref='table' data={ this.props.data } pagination exportCSV={ true } hover striped options={options}>
          <TableHeaderColumn dataField='sucursales' isKey={ true } dataSort={ true } width='280'>Sucursales</TableHeaderColumn>
          <TableHeaderColumn dataField='num_creditos' dataSort={ true } width='150'># Creditos</TableHeaderColumn>
          <TableHeaderColumn dataField='monto_credito' dataSort={ true } width='150'>Monto Creditos</TableHeaderColumn>
          <TableHeaderColumn dataField='cap_activo' dataSort={ true } width='150'>Cap Activo</TableHeaderColumn>
          <TableHeaderColumn dataField='cap_ndevenga' dataSort={ true } width='150'>Cap No Devenga</TableHeaderColumn>
          <TableHeaderColumn dataField='cap_vencido' dataSort={ true } width='150'>Cap Vencido</TableHeaderColumn>
          <TableHeaderColumn dataField='cartera_afectada' dataSort={ true } width='150'>Cartera Afectada</TableHeaderColumn>
          <TableHeaderColumn dataField='saldo_cartera' dataSort={ true } width='150'>Saldo Cartera</TableHeaderColumn>
          <TableHeaderColumn dataField='mora' width='150' dataFormat={this.CalculoMora}>% Mora</TableHeaderColumn>
          <TableHeaderColumn dataField='action' width='150' dataFormat={this.buttonAction}>Ver</TableHeaderColumn>
        </BootstrapTable>
      </Paper>
    );
  }
}

export default ReporteAgencias;