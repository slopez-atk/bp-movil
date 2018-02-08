import React from 'react';
import {BootstrapTable, TableHeaderColumn} from 'react-bootstrap-table';
import Paper from 'material-ui/Paper';
import PercentIndicadoresTable from "./PercentIndicadoresTable";


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


  calcularTotales(){
    let cantidad = 0;
    let cap_activo = 0;
    let cap_ndevenga = 0;
    let cartera_riesgo = 0;
    let cap_vencido = 0;
    for(let i=0; i < this.props.data.length; i++){
      cap_activo += parseFloat(this.props.data[i]["cap_activo"]);
      cap_ndevenga += parseFloat(this.props.data[i]["cap_ndevenga"]);
      cap_vencido += parseFloat(this.props.data[i]["cap_vencido"]);
      cartera_riesgo += parseFloat(this.props.data[i]["cartera_riesgo"]);
      cantidad += parseFloat(this.props.data[i]["cantidad"]);
    }
    return [cantidad, cap_activo, cap_ndevenga, cartera_riesgo, cap_vencido];
  }

  render(){
    const options = {
      toolBar: this.createCustomToolBar
    };
    let porcentajes = this.calcularTotales();
    return(
      <div>
        <Paper zDepth={3} className="top-space padding">
          <h4 className="top-space" style={{color: "#FFC107"}}>{ this.props.title }</h4>
          <div>
            <BootstrapTable ref='table' data={ this.props.data } exportCSV={ true } hover options={options}>
              <TableHeaderColumn dataField='clave' isKey={ true } dataSort={ true } width='250'>Indicador</TableHeaderColumn>
              <TableHeaderColumn dataField='cantidad' dataSort={ true } width='250'>Cantidad</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_activo' dataSort={ true } width='250'>Capital Activo</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_ndevenga' dataSort={ true } width='250'>Capital no Devenga</TableHeaderColumn>
              <TableHeaderColumn dataField='cartera_riesgo' dataSort={ true } width='250'>Cartera Riesgo</TableHeaderColumn>
              <TableHeaderColumn dataField='cap_vencido' dataSort={ true } width='250'>Capital Vencido</TableHeaderColumn>
            </BootstrapTable>
          </div>
          <h4 className="top-space" style={{color: "#FFC107"}}>Tabla de Porcentajes</h4>
          <div>
            <PercentIndicadoresTable data={this.props.data} cantidad={porcentajes[0]} cap_activo={porcentajes[1]} cap_ndevenga={porcentajes[2]} cartera_riesgo={porcentajes[3]} cap_vencido={porcentajes[4]}/>
          </div>
        </Paper>

        <Paper/>
      </div>
    );
  }
}

export default IndicadoresTable;