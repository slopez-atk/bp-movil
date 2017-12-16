import React from 'react';
import {BootstrapTable, TableHeaderColumn} from 'react-bootstrap-table';
import Paper from 'material-ui/Paper';
import RaiseButton from 'material-ui/RaisedButton';

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


  buttonAction(cell, row){
    return(
      <RaiseButton primary label="Ver" onClick={()=>  this.props.onClick(row.asesor) }/>
    );
  }


  render(){
    const options = {
      toolBar: this.createCustomToolBar
    };
    return(
      <Paper zDepth={2} className="top-space padding">

          <BootstrapTable ref='table' data={ this.props.data } pagination exportCSV={ true } hover striped options={options}>
            <TableHeaderColumn dataField='asesor' isKey={ true } dataSort={ true } width='280'>Asesor</TableHeaderColumn>
            <TableHeaderColumn dataField='cap_activo' dataSort={ true } width='150'>Cap Activo</TableHeaderColumn>
            <TableHeaderColumn dataField='cap_ndevenga' dataSort={ true } width='150'>Cap No Devenga</TableHeaderColumn>
            <TableHeaderColumn dataField='cap_vencido' dataSort={ true } width='150'>Cap Vencido</TableHeaderColumn>
            <TableHeaderColumn dataField='cartera_afectada' dataSort={ true } width='150'>Cartera Afectada</TableHeaderColumn>
            <TableHeaderColumn dataField='saldo_cartera' dataSort={ true } width='150'>Saldo Cartera</TableHeaderColumn>
            <TableHeaderColumn dataField='action' width='150' dataFormat={this.buttonAction}>Ver</TableHeaderColumn>

          </BootstrapTable>

      </Paper>
    );
  }
}

export default ReporteAsesor;