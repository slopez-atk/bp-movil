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
              <TableHeaderColumn dataField='socio' isKey={ true } dataSort={ true } width='170'>Socio</TableHeaderColumn>
              <TableHeaderColumn dataField='nombre' dataSort={ true } width='380'>Nombre</TableHeaderColumn>
              <TableHeaderColumn dataField='cedula' dataSort={ true } width='180'>Cedula</TableHeaderColumn>
              <TableHeaderColumn dataField='edad' dataSort={ true } width='130'>Edad</TableHeaderColumn>
              <TableHeaderColumn dataField='genero' dataSort={ true } width='260'>Genero</TableHeaderColumn>
              <TableHeaderColumn dataField='credito' dataSort={ true } width='250'>credito</TableHeaderColumn>
              <TableHeaderColumn dataField='fecha_concesion' dataSort={ true } width='250'>Fecha Concesion</TableHeaderColumn>
              <TableHeaderColumn dataField='calificacion' dataSort={ true } width='150'>Calificacion</TableHeaderColumn>
              <TableHeaderColumn dataField='garantia_vima' dataSort={ true } width='280'>Garantia Vima</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_activo' dataSort={ true } width='150'>Cap Activo</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_ndevenga' dataSort={ true } width='150'>Cap NoDevenga</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_vencido' dataSort={ true } width='150'>Cap Vencido</TableHeaderColumn>
              <TableHeaderColumn dataField='cartera_riesgo' dataSort={ true } width='180'>Cartera Riesgo</TableHeaderColumn>
            </BootstrapTable>
          </div>
        </Paper>
      </div>
    );
  }
}

export default TablaCreditos;