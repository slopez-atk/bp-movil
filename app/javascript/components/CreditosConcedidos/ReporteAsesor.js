import React from 'react';
import {BootstrapTable, TableHeaderColumn} from 'react-bootstrap-table';
import Paper from 'material-ui/Paper';
import RaiseButton from 'material-ui/RaisedButton';
import 'react-bootstrap-table/dist/react-bootstrap-table.min.css';

class ReporteAsesor extends React.Component{
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

  calculoCreditosMora(cell, row){
    let creditos_mora = ((parseFloat(row.creditos_morosos)*100)/parseFloat(row.numero_creditos)).toFixed(2);
    return(
      <td>{creditos_mora}%</td>
    );
  }

  calculoSaldoMora(cell, row){
    let saldos_mora = ((parseFloat(row.saldo_capital_pend)*100)/parseFloat(row.saldo_cartera)).toFixed(2);
    return(
      <td>{saldos_mora}%</td>
    );
  }


  buttonAction(cell, row){
    if(row.sucursal === "Total"){
      return(
        <h5>-</h5>
      )
    } else {
      return(
        <RaiseButton primary label="Ver" onClick={()=>  this.props.onClick(row.asesor) }/>
      );
    }
  }

  componentWillMount(){
    this.calcularSumatorias();
  }

  calcularSumatorias(){
    let data = this.props.data;
    let suma_creditos_morosos = 0;
    let suma_saldo_pendiente = 0;
    let suma_numero_creditos = 0;
    let suma_saldo_cartera = 0;
    for(let i=0; i<data.length; i++){
      suma_creditos_morosos += parseFloat(data[i]["creditos_morosos"]);
      suma_saldo_pendiente += parseFloat(data[i]["saldo_capital_pend"]);
      suma_numero_creditos += parseFloat(data[i]["numero_creditos"]);
      suma_saldo_cartera += parseFloat(data[i]["saldo_cartera"]);

    }
    let totales = {asesor: 'Total', creditos_morosos: suma_creditos_morosos, saldo_capital_pend: suma_saldo_pendiente.toFixed(2) ,numero_creditos: suma_numero_creditos, saldo_cartera: suma_saldo_cartera.toFixed(2)};
    data.push(totales);
  }


  render(){
    const options = {
      toolBar: this.createCustomToolBar
    };

    return(
      <Paper zDepth={2} className="top-space padding">

          <BootstrapTable ref='table' data={ this.props.data } pagination exportCSV={ true } hover striped options={options}>
            <TableHeaderColumn dataField='asesor' isKey={ true } dataSort={ true } width='200'>Asesores</TableHeaderColumn>
            <TableHeaderColumn dataField='creditos_morosos'  dataSort={ true } width='150'># Creditos Morosos</TableHeaderColumn>
            <TableHeaderColumn dataField='saldo_capital_pend'  dataSort={ true } width='150'>Saldo Capital Pendiente</TableHeaderColumn>
            <TableHeaderColumn dataField='numero_creditos' dataSort={ true } width='150'># Total Creditos</TableHeaderColumn>
            <TableHeaderColumn dataField='saldo_cartera' dataSort={ true } width='150'>Saldo Total</TableHeaderColumn>
            <TableHeaderColumn dataField='creditos_mora' width='150' dataFormat={this.calculoCreditosMora}>% Creditos Mora</TableHeaderColumn>
            <TableHeaderColumn dataField='saldos_mora' width='150' dataFormat={this.calculoSaldoMora}>% Saldo Mora</TableHeaderColumn>
            <TableHeaderColumn dataField='action' width='150' dataFormat={this.buttonAction}>Ver</TableHeaderColumn>

          </BootstrapTable>

      </Paper>
    );
  }
}

export default ReporteAsesor;