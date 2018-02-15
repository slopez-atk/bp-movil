import React from 'react';
import {BootstrapTable, TableHeaderColumn} from 'react-bootstrap-table';
import Paper from 'material-ui/Paper';
import PercentIndicadoresColocadosTable from "./PercentIndicadoresColocadosTable";


class IndicadoresColocadosTable extends React.Component {
  constructor(props) {
    super(props)
  }

  createCustomToolBar = props => {
    return (
      <div style={{margin: '15px'}}>
        {props.components.btnGroup}
        <div className='col-xs-8 col-sm-4 col-md-4 col-lg-2'>
          {props.components.searchPanel}
        </div>
      </div>
    );
  };


  calcularTotales() {
    let cantidad = 0;
    let monto_real = 0;

    for (let i = 0; i < this.props.data.length; i++) {
      monto_real += parseFloat(this.props.data[i]["monto_real"]);
      cantidad += parseFloat(this.props.data[i]["cantidad"]);
    }
    return [cantidad, monto_real];
  }

  render() {
    const options = {
      toolBar: this.createCustomToolBar
    };
    let porcentajes = this.calcularTotales();
    return (
      <div>
        <Paper zDepth={3} className="top-space padding">
          <h4 className="top-space" style={{color: "#FFC107"}}>{this.props.title}</h4>
          <div>
            <BootstrapTable ref='table' data={this.props.data} exportCSV={true} hover options={options}>
              <TableHeaderColumn dataField='clave' isKey={true} dataSort={true}
                                 width='250'>Indicador</TableHeaderColumn>
              <TableHeaderColumn dataField='cantidad' dataSort={true} width='250'>Cantidad</TableHeaderColumn>
              <TableHeaderColumn dataField='monto_real' dataSort={true} width='250'>Monto Real</TableHeaderColumn>
            </BootstrapTable>
          </div>
          <h4 className="top-space" style={{color: "#FFC107"}}>Tabla de Porcentajes</h4>
          <div>
            <PercentIndicadoresColocadosTable data={this.props.data} cantidad={porcentajes[0]} monto_real={porcentajes[1]}/>
          </div>
        </Paper>
      </div>
    );
  }
}

export default IndicadoresColocadosTable;