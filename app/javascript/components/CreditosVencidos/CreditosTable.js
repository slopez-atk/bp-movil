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
              <TableHeaderColumn dataField='socio' dataSort={ true } width='150' isKey={ true } filter={ { type: 'TextFilter', delay: 1000 }}>Socio</TableHeaderColumn>
              <TableHeaderColumn dataField='nombre' dataSort={ true } width='380' filter={ { type: 'TextFilter', delay: 1000 }}>Nombre</TableHeaderColumn>
              <TableHeaderColumn dataField='cedula' dataSort={ true } width='150' filter={ { type: 'TextFilter', delay: 1000 }}>Cedula</TableHeaderColumn>
              <TableHeaderColumn dataField='tip_id' dataSort={ true } width='80'>Tip</TableHeaderColumn>
              <TableHeaderColumn dataField='genero' dataSort={ true } width='100'>Genero</TableHeaderColumn>
              <TableHeaderColumn dataField='edad' dataSort={ true } width='100'>Edad</TableHeaderColumn>
              <TableHeaderColumn dataField='credito' dataSort={ true } width='150' filter={ { type: 'TextFilter', delay: 1000 }}>Crédito</TableHeaderColumn>
              <TableHeaderColumn dataField='codigo_perioc' dataSort={ true } width='140'>Periodicidad</TableHeaderColumn>
              <TableHeaderColumn dataField='fecha_ingreso' dataSort={ true } width='150'>Fecha Ingreso</TableHeaderColumn>
              <TableHeaderColumn dataField='fecha_concesion' dataSort={ true } width='150'>Fecha Conseción</TableHeaderColumn>
              <TableHeaderColumn dataField='fecha_vencimiento' dataSort={ true } width='150'>Fecha Vencim</TableHeaderColumn>
              <TableHeaderColumn dataField='diasmora_pd' dataSort={ true } width='80'>Días mora</TableHeaderColumn>
              <TableHeaderColumn dataField='cuotas_credito' dataSort={ true } width='80'>Cuotas crédito</TableHeaderColumn>
              <TableHeaderColumn dataField='calificacion' dataSort={ true } width='100'>Calificación</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_activo' dataSort={ true } width='150'>Cap. Activo</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_ndevenga' dataSort={ true } width='150'>Cap No Devenga</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_vencido' dataSort={ true } width='150'>Cap Vencido</TableHeaderColumn>
              <TableHeaderColumn dataField='cartera_riesgo' dataSort={ true } width='150'>Cartera Riesgo</TableHeaderColumn>
              <TableHeaderColumn dataField='saldo_cartera' dataSort={ true } width='150'>Saldo Cartera</TableHeaderColumn>
              <TableHeaderColumn dataField='valor_cancela' dataSort={ true } width='150'>Valor Cancela</TableHeaderColumn>
              <TableHeaderColumn dataField='provision_requerida' dataSort={ true } width='150'>Provisión</TableHeaderColumn>
              <TableHeaderColumn dataField='origen_recursos' dataSort={ true } width='350'>Origen</TableHeaderColumn>
              <TableHeaderColumn dataField='oficina' dataSort={ true } width='260'>Agencia</TableHeaderColumn>
              <TableHeaderColumn dataField='cartera_heredada' dataSort={ true } width='290' filter={ { type: 'TextFilter', delay: 1000 }}>Cartera Heredada</TableHeaderColumn>
              <TableHeaderColumn dataField='asesor' dataSort={ true } width='290' filter={ { type: 'TextFilter', delay: 1000 }}>Asesor</TableHeaderColumn>
            </BootstrapTable>
          </div>
        </Paper>
      </div>
    );
  }
}

export default CreditosTable;