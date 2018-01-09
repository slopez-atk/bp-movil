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
        <TableHeaderColumn dataField='credito' isKey={ true } dataSort={ true } width={"300"} filter={ { type: 'TextFilter', delay: 1000 }}>Crédito</TableHeaderColumn>
        <TableHeaderColumn dataField='socio' dataSort={ true } width={300} filter={ { type: 'TextFilter', delay: 1000 }}>Socio</TableHeaderColumn>
        <TableHeaderColumn dataField='nombre' dataSort={ true } filter={ { type: 'TextFilter', delay: 1000 }} width={"340"}>Nombres</TableHeaderColumn>
        <TableHeaderColumn dataField='fecha_concesion' dataSort={ true } filter={ { type: 'TextFilter', delay: 1000 }} width={"300"}>Fecha Concesion</TableHeaderColumn>
        <TableHeaderColumn dataField='monto_real' dataSort={ true } filter={ { type: 'TextFilter', delay: 1000 }} width={"300"}>Monto Real</TableHeaderColumn>
        <TableHeaderColumn dataField='saldo_cartera' dataSort={ true } width={"300"}>Saldo Cartera</TableHeaderColumn>
        <TableHeaderColumn dataField='saldo' dataSort={ true } width={"300"}>Valor Cuota</TableHeaderColumn>
        <TableHeaderColumn dataField='fecha' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }} width={"300"}>Fecha proxima cuota</TableHeaderColumn>
        <TableHeaderColumn dataField='pago' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }} width={"300"}>Pago Realizado</TableHeaderColumn>
        <TableHeaderColumn dataField='pago_realizado' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }} width={"300"}>Fecha Pago Realizado</TableHeaderColumn>
        <TableHeaderColumn dataField='valor_recuperado' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }} width={"300"}>Fecha Pago Realizado</TableHeaderColumn>
        <TableHeaderColumn dataField='fecha_prox_pago_variable' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }} width={"300"}>Fecha Pago Realizado</TableHeaderColumn>
        <TableHeaderColumn dataField='dias_mora' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }} width={"300"}>Dias mora</TableHeaderColumn>
        <TableHeaderColumn dataField='sucursal' dataSort={ true } width={"300"}>Sucursal</TableHeaderColumn>
        <TableHeaderColumn dataField='cartera_heredada' dataSort={ true } width={"300"}>Cartera Heredada</TableHeaderColumn>
        <TableHeaderColumn dataField='asesor' dataSort={ true } width={"300"}>ASESOR</TableHeaderColumn>
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