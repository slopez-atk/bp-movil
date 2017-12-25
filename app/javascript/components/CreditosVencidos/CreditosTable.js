import React from 'react';
import {BootstrapTable, TableHeaderColumn} from 'react-bootstrap-table';
import Paper from 'material-ui/Paper';

class CreditosTable extends React.Component{
  constructor(props){
    super(props);
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



  render(){
    const options = {
      toolBar: this.createCustomToolBar
    };
    return(
      <div>
        <h4 className="top-space" style={{color: "#FFC107"}}>Detalles de los créditos</h4>
        <Paper zDepth={3} className="top-space padding">
          <div className="table-responsive">
            <BootstrapTable ref='table' data={ this.props.data } pagination exportCSV={ true }  hover options={options}>
              <TableHeaderColumn dataField='fecha_ingreso' isKey={ true } dataSort={ true } width='150'>Fecha Ingreso</TableHeaderColumn>
              <TableHeaderColumn dataField='socio' dataSort={ true } width='150'>Socio</TableHeaderColumn>
              <TableHeaderColumn dataField='credito' dataSort={ true } width='150'>Credito</TableHeaderColumn>
              <TableHeaderColumn dataField='origen_recursos' dataSort={ true } width='150'>Origen</TableHeaderColumn>
              <TableHeaderColumn dataField='provision_requerida' dataSort={ true } width='150'>Provision</TableHeaderColumn>
              <TableHeaderColumn dataField='codigo_perioc' dataSort={ true } width='150'>Codigo p</TableHeaderColumn>
              <TableHeaderColumn dataField='cuotas_credito' dataSort={ true } width='80'>Cuotas credito</TableHeaderColumn>
              <TableHeaderColumn dataField='nombre' dataSort={ true } width='150'>Nombre</TableHeaderColumn>
              <TableHeaderColumn dataField='tip_id' dataSort={ true } width='150'>Tip</TableHeaderColumn>
              <TableHeaderColumn dataField='cedula' dataSort={ true } width='150'>Cedula</TableHeaderColumn>
              <TableHeaderColumn dataField='genero' dataSort={ true } width='150'>Genero</TableHeaderColumn>
              <TableHeaderColumn dataField='edad' dataSort={ true } width='150'>Edad</TableHeaderColumn>
              <TableHeaderColumn dataField='fecha_nacimiento' dataSort={ true } width='150'>fecha nac</TableHeaderColumn>
              <TableHeaderColumn dataField='calificacion' dataSort={ true } width='150'>calificacion</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_activo' dataSort={ true } width='150'>Cap. Activo</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_ndevenga' dataSort={ true } width='150'>Cap No Devenga</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_vencido' dataSort={ true } width='150'>Cap Vencido</TableHeaderColumn>
              <TableHeaderColumn dataField='cartera_riesgo' dataSort={ true } width='150'>Cartera Riesgo</TableHeaderColumn>
              <TableHeaderColumn dataField='saldo_cartera' dataSort={ true } width='150'>Saldo Cartera</TableHeaderColumn>
              <TableHeaderColumn dataField='fecha_concesion' dataSort={ true } width='150'>Fecha Conce</TableHeaderColumn>
              <TableHeaderColumn dataField='fecha_vencimiento' dataSort={ true } width='150'>Fecha Vencim</TableHeaderColumn>
              <TableHeaderColumn dataField='valor_cancela' dataSort={ true } width='150'>Valor Cancela</TableHeaderColumn>
              <TableHeaderColumn dataField='diasmora_pd' dataSort={ true } width='80'>Dias mora</TableHeaderColumn>
              <TableHeaderColumn dataField='oficina' dataSort={ true } width='120'>Oficina</TableHeaderColumn>
              <TableHeaderColumn dataField='cartera_heredada' dataSort={ true } width='200'>Cartera Heredada</TableHeaderColumn>
              <TableHeaderColumn dataField='asesor' dataSort={ true } width='200'>Asesor</TableHeaderColumn>
            </BootstrapTable>
          </div>
        </Paper>
      </div>
    );
  }
}

export default CreditosTable;