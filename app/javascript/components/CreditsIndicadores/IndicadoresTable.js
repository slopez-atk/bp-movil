import React from 'react';
import {BootstrapTable, TableHeaderColumn} from 'react-bootstrap-table';
import Paper from 'material-ui/Paper';

class IndicadoresTable extends React.Component{
  constructor(props){
    super(props)
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
          <h4 className="top-space" style={{color: "#FFC107"}}>{ this.props.title }</h4>
          <div>
            <BootstrapTable ref='table' data={ this.props.data } exportCSV={ true } hover options={options}>
              <TableHeaderColumn dataField='clave' isKey={ true } dataSort={ true } width='250'>Indicador</TableHeaderColumn>
              <TableHeaderColumn dataField='cantidad' dataSort={ true } width='250'>Cantidad</TableHeaderColumn>
              <TableHeaderColumn dataField='saldo' dataSort={ true } width='250'>Saldo</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_activo' dataSort={ true } width='250'>Capital Activo</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_ndevenga' dataSort={ true } width='250'>Capital no Devenga</TableHeaderColumn>
              <TableHeaderColumn dataField='cartera_riesgo' dataSort={ true } width='250'>Cartera Riesgo</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_vencido' dataSort={ true } width='250'>Capital Vencido</TableHeaderColumn>
            </BootstrapTable>
          </div>
        </Paper>
      </div>
    );
  }
}

export default IndicadoresTable;