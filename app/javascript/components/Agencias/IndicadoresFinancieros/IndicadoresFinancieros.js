import React from 'react';
import {Table, TableBody, TableFooter, TableHeader, TableHeaderColumn, tr, td} from 'material-ui/Table';
import Paper from 'material-ui/Paper';
import RaisedButton from 'material-ui/RaisedButton';
import ReactHTMLTableToExcel from 'react-html-table-to-excel';

const style = {
  tr: {
    textAlign: 'center',
    whiteSpace: 'normal',
    wordWrap: 'break-word',
  },
  markRow: {
    backgroundColor:'#3F51B5',
    color: '#fff'
  },
  sizeRow: {
    width: '250px'
  },
  headerRow: {
    backgroundColor:'#FFC107',
    color: "#000",
    textAlign: 'center',
    fontSize: "15px"
  },
  cuentasRow: {
    width: "250px",
    fontWeight: "bold"
  }
};
class IndicadoresFinancieros extends React.Component{
  constructor(props){
    super(props);
  }

  getBody(){
    let result = [];
    result.push(
      <div>

      </div>
    );
    return result;
  }

  getRow(array, marked){
    return array.map((row, index) =>{
      let estilos = {};
      if(marked){
        estilos = {
          backgroundColor:'#3F51B5',
          color: '#fff'
        }
      }
      return <td style={estilos} key={index}>{ row }</td>
    })
  }




  render(){
    return(
      <div>
        <ReactHTMLTableToExcel
          id="test-table-xls-button"
          className="btn btn-inverse top-space bottom-space"
          table="table-to-xls"
          filename="tablexls"
          sheet="tablexls"
          buttonText="Descargar excel"/>
        <Paper zDepth={4}>
          <div className="table-responsive top-space">
            <table className="table table-striped table-hover table-bordered padding" id="table-to-xls">
              <thead>
                <tr>
                  <th style={style.headerRow}>Cuenta</th>
                  <th style={style.headerRow}>Diciembre</th>
                  <th style={style.headerRow}>Enero</th>
                  <th style={style.headerRow}>Febrero</th>
                  <th style={style.headerRow}>Marzo</th>
                  <th style={style.headerRow}>Abril</th>
                  <th style={style.headerRow}>Mayo</th>
                  <th style={style.headerRow}>Junio</th>
                  <th style={style.headerRow}>Julio</th>
                  <th style={style.headerRow}>Agosto</th>
                  <th style={style.headerRow}>Septiembre</th>
                  <th style={style.headerRow}>Octubre</th>
                  <th style={style.headerRow}>Noviembre</th>
                  <th style={style.headerRow}>Diciembre</th>
                  <th style={style.headerRow}>Grafica</th>
                </tr>
              </thead>
              <tbody>
              <tr>
                <td style={style.markRow}>Activos</td>
                {this.getRow(this.props.activos, true)}
                <td ><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.activos, "Gráfica de cuenta - Activos")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Fondos</td>
                {this.getRow(this.props.fondos, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.fondos, "Gráfica de cuenta - Fondos")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Caja Bancos</td>
                {this.getRow(this.props.caja_bancos, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.caja_bancos, "Gráfica de cuenta - Caja Bancos")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Cartera Bruta</td>
                {this.getRow(this.props.cartera_bruta, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.cartera_bruta, "Gráfica de cuenta - Cartera Bruta")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Cartera Bruta - microcrédito</td>
                {this.getRow(this.props.cartera_bruta_microcredito, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.cartera_bruta_microcredito, "Gráfica de cuenta - Cartera Bruta-microcrédito")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Cartera en riesgo total</td>
                {this.getRow(this.props.cartera_riesgo, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.cartera_riesgo, "Gráfica de cuenta - Cartera en riesgo total")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Reserva por préstamos incobrables</td>
                {this.getRow(this.props.recerva_prestamo, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.recerva_prestamo, "Gráfica de cuenta - Reserva por préstamos incobrables")}/></td>
              </tr>

              <tr>
                <td style={style.markRow}>Pasivos</td>
                {this.getRow(this.props.pasivos, true)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.pasivos, "Gráfica de cuenta - Pasivos")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Obligaciones con el público</td>
                {this.getRow(this.props.obligaciones, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.obligaciones, "Gráfica de cuenta - Obligaciones con el público")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Depósitos a la vista</td>
                {this.getRow(this.props.deposito_vista, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.deposito_vista, "Gráfica de cuenta - Depósitos a la vista")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>DPF + Cesantía</td>
                {this.getRow(this.props.dpf_cesantia, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.dpf_cesantia, "Gráfica de cuenta -")}/></td>
              </tr>

              <tr>
                <td style={style.markRow} >Patrimonio</td>
                {this.getRow(this.props.patrimonio, true)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.patrimonio, "Gráfica de cuenta - Patrimonio")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Certificados de aportación</td>
                {this.getRow(this.props.certificados_aportacion, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.gastos_personal, "Gráfica de cuenta - Certificados de aportación")}/></td>
              </tr>

              <tr>
                <td style={style.markRow}>Ingresos Totales</td>
                {this.getRow(this.props.ingresos_totales, true)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.ingresos_totales, "Gráfica de cuenta - Ingresos Totales")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Intereses y descuentos ganados</td>
                {this.getRow(this.props.intereses_descuentos, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.intereses_descuentos, "Gráfica de cuenta - Intereses y descuentos ganados")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Operaciones Interfinancieras</td>
                {this.getRow(this.props.operaciones_interfinancieras, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.operaciones_interfinancieras, "Gráfica de cuenta - Operaciones Interfinancieras")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Intereses en inversiones</td>
                {this.getRow(this.props.intereses_inversiones, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.intereses_inversiones, "Gráfica de cuenta - Intereses en inversiones")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Intereses y descuentos de cartera de crédito</td>
                {this.getRow(this.props.intereses_cartera_credito, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.intereses_cartera_credito, "Gráfica de cuenta - Intereses y descuentos de cartera de crédito")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Ingresos por servicios</td>
                {this.getRow(this.props.ingresos_servicio, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.ingresos_servicio, "Gráfica de cuenta - Ingresos por servicios")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Otros ingresos</td>
                {this.getRow(this.props.otros_ingresos, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.otros_ingresos, "Gráfica de cuenta - Otros ingresos")}/></td>
              </tr>

              <tr>
                <td style={style.markRow}>Gastos Totales</td>
                {this.getRow(this.props.gastos_totales, true)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.gastos_totales, "Gráfica de cuenta - Gastos Totales")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Gastos Financieros</td>
                {this.getRow(this.props.gastos_financieros, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.gastos_financieros, "Gráfica de cuenta - Gastos Financieros")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Intereses Causados</td>
                {this.getRow(this.props.intereses_causados, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.intereses_causados, "Gráfica de cuenta - Intereses Causados")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Gastos de Provisión</td>
                {this.getRow(this.props.gastos_provision, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.gastos_provision, "Gráfica de cuenta - Gastos de Provisión")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Gastos Operacionales</td>
                {this.getRow(this.props.gastos_operacionales, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.gastos_operacionales, "Gráfica de cuenta - Gastos Operacionales")}/></td>
              </tr>

              <tr>
                <td style={style.cuentasRow}>Gastos de Personal</td>
                {this.getRow(this.props.gastos_personal, false)}
                <td><RaisedButton label="Ver" primary onClick={()=>  this.props.onClick(this.props.gastos_personal, "Gráfica de cuenta - Gastos de Personal")}/></td>
              </tr>
              </tbody>
            </table>
          </div>
        </Paper>
      </div>
    );
  }
}

export default IndicadoresFinancieros;