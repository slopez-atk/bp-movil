import React from 'react';
import {BootstrapTable, TableHeaderColumn} from 'react-bootstrap-table';
import Paper from 'material-ui/Paper';

class PerWeek extends React.Component{

  constructor(props){
    super(props);
    this.state = {
      cantidad: 0,
      saldo: 0
    }
  }

  getFilteredResult = ()=> {
    let result = this.refs.table.getTableDataIgnorePaging();
    let cantidad = 0;
    let saldo = 0;
    for(let i = 0; i<result.length; i++){
      saldo += result[i]['saldo'];
      cantidad ++;
    }
    this.setState({
      cantidad: cantidad,
      saldo: saldo
    })
  };

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

  renderTable(data){

    if(Object.keys(data).length === 0) {
      data = []
    }

    const options = {
      onRowMouseOver: this.getFilteredResult,
      toolBar: this.createCustomToolBar
    };
    return(
      <BootstrapTable ref='table' data={ data } pagination exportCSV={ true } striped hover condensed options={ options }>
        <TableHeaderColumn dataField='credito' isKey={ true } dataSort={ true }>CREDITO</TableHeaderColumn>
        <TableHeaderColumn dataField='socio' dataSort={ true }>SOCIO</TableHeaderColumn>
        <TableHeaderColumn dataField='nombre' dataSort={ true } filter={ { type: 'TextFilter', delay: 1000 }}>NOMBRES</TableHeaderColumn>
        <TableHeaderColumn dataField='saldo' dataSort={ true }>SALDO</TableHeaderColumn>
        <TableHeaderColumn dataField='fecha' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }}>FECHA</TableHeaderColumn>
        <TableHeaderColumn dataField='sucursal' dataSort={ true }>AGENCIA</TableHeaderColumn>
        <TableHeaderColumn dataField='asesor' dataSort={ true }>ASESOR</TableHeaderColumn>
      </BootstrapTable>
    );
  }

  render(){
    return(
      <div className="col-xs-12 col-md-11 top-space">
        <Paper zDepth={3} style={{padding: '4 4'}}>
          { this.renderTable( this.props.data ) }
        </Paper>
        <h4>Total: {this.state.saldo}</h4>
        <h4>Cantidad: {this.state.cantidad}</h4>
      </div>
    );
  }
};

export default PerWeek;