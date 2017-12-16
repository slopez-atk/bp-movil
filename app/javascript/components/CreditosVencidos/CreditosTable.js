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
              <TableHeaderColumn dataField='socio' isKey={ true } dataSort={ true } width='80'>Socio</TableHeaderColumn>
              <TableHeaderColumn dataField='credito' dataSort={ true } width='80'>credito</TableHeaderColumn>
              <TableHeaderColumn dataField='origen_recursos' dataSort={ true } width='80'>origen</TableHeaderColumn>
              <TableHeaderColumn dataField='provision_requerida' dataSort={ true } width='80'>provision</TableHeaderColumn>
              <TableHeaderColumn dataField='codigo_perioc' dataSort={ true } width='80'>codigo p</TableHeaderColumn>
              <TableHeaderColumn dataField='cuotas_credito' dataSort={ true } width='80'>cuotas credito</TableHeaderColumn>
              <TableHeaderColumn dataField='nombre' dataSort={ true } width='150'>nombre</TableHeaderColumn>
              <TableHeaderColumn dataField='tip_id' dataSort={ true } width='80'>tip</TableHeaderColumn>
              <TableHeaderColumn dataField='cedula' dataSort={ true } width='80'>cedula</TableHeaderColumn>
              <TableHeaderColumn dataField='genero' dataSort={ true } width='80'>genero</TableHeaderColumn>
              <TableHeaderColumn dataField='edad' dataSort={ true } width='80'>edad</TableHeaderColumn>
              <TableHeaderColumn dataField='fecha_nacimiento' dataSort={ true } width='80'>fecha nac</TableHeaderColumn>
              <TableHeaderColumn dataField='calificacion' dataSort={ true } width='80'>calificacion</TableHeaderColumn>
              <TableHeaderColumn dataField='cartera_riesgo' dataSort={ true } width='80'>cartera</TableHeaderColumn>
              <TableHeaderColumn dataField='saldo_cartera' dataSort={ true } width='80'>saldo cartera</TableHeaderColumn>
              <TableHeaderColumn dataField='fecha_concesion' dataSort={ true } width='80'>fecha con</TableHeaderColumn>
              <TableHeaderColumn dataField='fecha_vencimiento' dataSort={ true } width='80'>fecha ve</TableHeaderColumn>
              <TableHeaderColumn dataField='valor_cancela' dataSort={ true } width='80'>Cap Vencido</TableHeaderColumn>
              <TableHeaderColumn dataField='diasmora_pd' dataSort={ true } width='80'>Cap Vencido</TableHeaderColumn>
              <TableHeaderColumn dataField='oficina' dataSort={ true } width='80'>Cap Vencido</TableHeaderColumn>
              <TableHeaderColumn dataField='cartera_heredada' dataSort={ true } width='80'>Cap Vencido</TableHeaderColumn>
              <TableHeaderColumn dataField='asesor' dataSort={ true } width='80'>Cap Vencido</TableHeaderColumn>
            </BootstrapTable>
          </div>
        </Paper>
      </div>
    );
  }
}

export default CreditosTable;