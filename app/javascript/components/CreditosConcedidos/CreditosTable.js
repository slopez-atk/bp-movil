import React from 'react';
import {BootstrapTable, TableHeaderColumn} from 'react-bootstrap-table';
import Paper from 'material-ui/Paper';
import 'react-bootstrap-table/dist/react-bootstrap-table.min.css';

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
          <div>
            <BootstrapTable ref='table' data={ this.props.data } pagination exportCSV={ true }  hover options={options}>
              <TableHeaderColumn dataField='codigo_socio' isKey={ true } dataSort={ true } width='120'>Código Socio</TableHeaderColumn>
              <TableHeaderColumn dataField='nombres' dataSort={ true } width='380'>Nombres</TableHeaderColumn>
              <TableHeaderColumn dataField='cedula' dataSort={ true } width='150'>Cédula</TableHeaderColumn>
              <TableHeaderColumn dataField='telefono' dataSort={ true } width='150'>Teléfono</TableHeaderColumn>
              <TableHeaderColumn dataField='celular' dataSort={ true } width='150'>Celular</TableHeaderColumn>
              <TableHeaderColumn dataField='provincia' dataSort={ true } width='150'>Provincia</TableHeaderColumn>
              <TableHeaderColumn dataField='canton' dataSort={ true } width='250'>Cantón</TableHeaderColumn>
              <TableHeaderColumn dataField='parroquia' dataSort={ true } width='300'>Parroquia</TableHeaderColumn>
              <TableHeaderColumn dataField='grupo_org' dataSort={ true } width='280'>Grupo org</TableHeaderColumn>
              <TableHeaderColumn dataField='numero_credito' dataSort={ true } width='120'>Crédito</TableHeaderColumn>
              <TableHeaderColumn dataField='dias_vencido' dataSort={ true } width='100'>Días Vencidos</TableHeaderColumn>
              <TableHeaderColumn dataField='saldo_disponible_ahorros' dataSort={ true } width='150'>Saldo disponible ahorros</TableHeaderColumn>
              <TableHeaderColumn dataField='saldo_bloqueado_ahorros' dataSort={ true } width='150'>Saldo bloqueado ahorros</TableHeaderColumn>
              <TableHeaderColumn dataField='certificados' dataSort={ true } width='150'>Certificados</TableHeaderColumn>
              <TableHeaderColumn dataField='saldo_encaje' dataSort={ true } width='150'>Saldo Encaje</TableHeaderColumn>
              <TableHeaderColumn dataField='saldo_cesantia' dataSort={ true } width='150'>Saldo Cesantía</TableHeaderColumn>
              <TableHeaderColumn dataField='monto_real' dataSort={ true } width='150'>Monto Real</TableHeaderColumn>
              <TableHeaderColumn dataField='saldo_capital_pend' dataSort={ true } width='150'>Saldo Capital Pendiente</TableHeaderColumn>
              <TableHeaderColumn dataField='valor_cancela' dataSort={ true } width='150'>Valor Cancela</TableHeaderColumn>
              <TableHeaderColumn dataField='valor_notificaciones' dataSort={ true } width='150'>Valor Notificaciones</TableHeaderColumn>
              <TableHeaderColumn dataField='valor_judicial' dataSort={ true } width='150'>Valor Judicial</TableHeaderColumn>
              <TableHeaderColumn dataField='capital_vencido' dataSort={ true } width='150'>Capital Vencido</TableHeaderColumn>
              <TableHeaderColumn dataField='fecha_vence' dataSort={ true } width='150'>Fecha Vence</TableHeaderColumn>
              <TableHeaderColumn dataField='total_vencido' dataSort={ true } width='150'>Total Vencido</TableHeaderColumn>
              <TableHeaderColumn dataField='por_vencer_manana' dataSort={ true } width='150'>Por Vencer Mañana</TableHeaderColumn>
              <TableHeaderColumn dataField='mcli_observac' dataSort={ true } width='150'>Mcli Observacion</TableHeaderColumn>
              <TableHeaderColumn dataField='estado_judi' dataSort={ true } width='150'>Estado Judicial</TableHeaderColumn>
              <TableHeaderColumn dataField='notificacion' dataSort={ true } width='150'>Notificación</TableHeaderColumn>
              <TableHeaderColumn dataField='origen_recursos' dataSort={ true } width='280'>Origen de Recursos</TableHeaderColumn>
              <TableHeaderColumn dataField='nom_grupo' dataSort={ true } width='300'>Nombre Grupo</TableHeaderColumn>
              <TableHeaderColumn dataField='nombre_sucursal' dataSort={ true } width='280'>Agencia</TableHeaderColumn>
              <TableHeaderColumn dataField='cartera_heredada' dataSort={ true } width='230'>Cartera Heredada</TableHeaderColumn>
              <TableHeaderColumn dataField='asesor' dataSort={ true } width='230'>Asesor</TableHeaderColumn>
            </BootstrapTable>
          </div>
        </Paper>
      </div>
    );
  }
}

export default CreditosTable;