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
    let recuperado = 0;
    for(let i = 0; i<result.length; i++){
      saldo += result[i]['saldo'];
      recuperado += result[i]['valor_recuperado'];
      cantidad ++;
    }
    this.setState({
      cantidad: cantidad,
      recuperado: recuperado,
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
        <TableHeaderColumn dataField='socio' dataSort={ true } width={"150"} filter={ { type: 'TextFilter', delay: 1000 }}>Socio</TableHeaderColumn>
        <TableHeaderColumn dataField='nombre' dataSort={ true } filter={ { type: 'TextFilter', delay: 1000 }} width={"380"}>Nombres</TableHeaderColumn>
        <TableHeaderColumn dataField='credito' isKey={ true } dataSort={ true } width={"150"} filter={ { type: 'TextFilter', delay: 1000 }}>Crédito</TableHeaderColumn>
        <TableHeaderColumn dataField='fecha_concesion' dataSort={ true } filter={ { type: 'TextFilter', delay: 1000 }} width={"250"}>Fecha Concesion</TableHeaderColumn>
        <TableHeaderColumn dataField='monto_real' dataSort={ true } filter={ { type: 'TextFilter', delay: 1000 }} width={"150"}>Monto Real</TableHeaderColumn>
        <TableHeaderColumn dataField='saldo_cartera' dataSort={ true } width={"150"}>Saldo Cartera</TableHeaderColumn>
        <TableHeaderColumn dataField='saldo' dataSort={ true } width={"150"}>Valor Cuota</TableHeaderColumn>
        <TableHeaderColumn dataField='pago_realizado' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }} width={"150"}>Pago Realizado</TableHeaderColumn>
        <TableHeaderColumn dataField='fecha_pago_realizado' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }} width={"300"}>Fecha Pago Realizado</TableHeaderColumn>
        <TableHeaderColumn dataField='fecha' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }} width={"150"}>Fecha proxima cuota</TableHeaderColumn>
        <TableHeaderColumn dataField='valor_recuperado' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }} width={"150"}>Valor Recuperado</TableHeaderColumn>
        <TableHeaderColumn dataField='condicion_pago' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }} width={"150"}>Condición de Pago</TableHeaderColumn>
        <TableHeaderColumn dataField='fecha_prox_pago_variable' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }} width={"300"}>Fecha Proximo Pago Variable</TableHeaderColumn>
        <TableHeaderColumn dataField='provision' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }} width={"150"}>Provisión</TableHeaderColumn>
        <TableHeaderColumn dataField='dias_mora' dataSort={ true }  filter={ { type: 'TextFilter', delay: 1000 }} width={"150"}>Dias mora</TableHeaderColumn>
        <TableHeaderColumn dataField='sucursal' dataSort={ true } width={"300"}>Sucursal</TableHeaderColumn>
        <TableHeaderColumn dataField='cartera_heredada' dataSort={ true } width={"300"}>Cartera Heredada</TableHeaderColumn>
        <TableHeaderColumn dataField='asesor' dataSort={ true } width={"300"}>ASESOR</TableHeaderColumn>
      </BootstrapTable>
    );
  }

  render(){
    return(
      <div className="col-xs-12 col-md-11 top-space">
        <h4>Total: {parseFloat(this.state.saldo).toFixed(2)}</h4>
        <h4>Cantidad: {this.state.cantidad}</h4>
        <h4>Valor Recuperado: {parseFloat(this.state.recuperado).toFixed(2)}</h4>
        <Paper zDepth={3} style={{padding: '4 4'}}>
          { this.renderTable( this.props.data ) }
        </Paper>
      </div>
    );
  }
};

export default PerWeek;