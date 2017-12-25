import React from 'react';
import {BootstrapTable, TableHeaderColumn} from 'react-bootstrap-table';
import Paper from 'material-ui/Paper';
import 'react-bootstrap-table/dist/react-bootstrap-table.min.css';

class TablaCreditos extends React.Component{
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
        <Paper zDepth={3} className="top-space padding">
          <div>
            <BootstrapTable ref='table' data={ this.props.datos } pagination exportCSV={ true }  hover options={options}>
              <TableHeaderColumn dataField='socio' isKey={ true } dataSort={ true } width='150'>Socio</TableHeaderColumn>
              <TableHeaderColumn dataField='credito' dataSort={ true } width='150'>credito</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_activo' dataSort={ true } width='150'>Cap Activo</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_ndevenga' dataSort={ true } width='150'>Cap NoDevenga</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_vencido' dataSort={ true } width='150'>Cap Vencido</TableHeaderColumn>
              <TableHeaderColumn dataField='calificacion' dataSort={ true } width='150'>Calificacion</TableHeaderColumn>
              <TableHeaderColumn dataField='cartera_riesgo' dataSort={ true } width='150'>Cartera Riesgo</TableHeaderColumn>
              <TableHeaderColumn dataField='nombre' dataSort={ true } width='150'>Nombre</TableHeaderColumn>
              <TableHeaderColumn dataField='cedula' dataSort={ true } width='150'>Cedula</TableHeaderColumn>
              <TableHeaderColumn dataField='tip_id' dataSort={ true } width='150'>Tip</TableHeaderColumn>
              <TableHeaderColumn dataField='fecha_concesion' dataSort={ true } width='150'>Fecha Concesion</TableHeaderColumn>

            </BootstrapTable>
          </div>
        </Paper>
      </div>
    );
  }
}

export default TablaCreditos;