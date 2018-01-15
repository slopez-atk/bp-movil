import React from 'react';
import {Table, TableBody, TableFooter, TableHeader, TableHeaderColumn, tr, td} from 'material-ui/Table';
import Paper from 'material-ui/Paper';
import RaisedButton from 'material-ui/RaisedButton';

const style = {
  tr: {
    textAlign: 'center',
    whiteSpace: 'normal',
    wordWrap: 'break-word',
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

  getRow(array){
    return array.map((row, index) =>{

      return <td style={style.tr} key={index}>{ row }</td>
    })
  }




  render(){
    return(
      <div>
        <Paper zDepth={4}>
          <div className="table-responsive top-space">
            <table className="table table-striped table-hover table-bordered">
              <thead>
                <tr>
                  <th>Cuenta</th>
                  <th>Diciembre</th>
                  <th>Enero</th>
                  <th>Febrero</th>
                  <th>Marzo</th>
                  <th>Abril</th>
                  <th>Mayo</th>
                  <th>Junio</th>
                  <th>Julio</th>
                  <th>Agosto</th>
                  <th>Septiembre</th>
                  <th>Octubre</th>
                  <th>Noviembre</th>
                  <th>Diciembre</th>
                  <th>Grafica</th>
                </tr>
              </thead>
              <tbody>
              <tr>
                <td style={{width: '250px'}}>Activos</td>
                {this.getRow(this.props.activos)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Fondos</td>
                {this.getRow(this.props.fondos)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Caja Bancos</td>
                {this.getRow(this.props.caja_bancos)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Cartera Bruta</td>
                {this.getRow(this.props.cartera_bruta)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Cartera Bruta - microcrédito</td>
                {this.getRow(this.props.cartera_bruta_microcredito)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Cartera en riesgo total</td>
                {this.getRow(this.props.cartera_riesgo)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td style={style.tr }>Reserva por préstamos incobrables</td>
                {this.getRow(this.props.recerva_prestamo)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Pasivos</td>
                {this.getRow(this.props.pasivos)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Obligaciones con el público</td>
                {this.getRow(this.props.obligaciones)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Depósitos a la vista</td>
                {this.getRow(this.props.deposito_vista)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>DPF + Cesantía</td>
                {this.getRow(this.props.dpf_cesantia)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Patrimonio</td>
                {this.getRow(this.props.patrimonio)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Certificados de aportación</td>
                {this.getRow(this.props.certificados_aportacion)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Ingresos Totales</td>
                {this.getRow(this.props.ingresos_totales)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Intereses y descuentos ganados</td>
                {this.getRow(this.props.intereses_descuentos)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Operaciones Interfinancieras</td>
                {this.getRow(this.props.operaciones_interfinancieras)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Intereses en inversiones</td>
                {this.getRow(this.props.intereses_inversiones)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Intereses y descuentos de cartera de crédito</td>
                {this.getRow(this.props.intereses_cartera_credito)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Ingresos por servicios</td>
                {this.getRow(this.props.ingresos_servicio)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Otros ingresos</td>
                {this.getRow(this.props.otros_ingresos)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Gastos Totales</td>
                {this.getRow(this.props.gastos_totales)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Gastos Financieros</td>
                {this.getRow(this.props.gastos_financieros)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Intereses Causados</td>
                {this.getRow(this.props.intereses_causados)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Gastos de Provisión</td>
                {this.getRow(this.props.gastos_provision)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Gastos Operacionales</td>
                {this.getRow(this.props.gastos_operacionales)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
              </tr>

              <tr>
                <td>Gastos de Personal</td>
                {this.getRow(this.props.gastos_personal)}
                <td><RaisedButton label="Ver" backgroundColor={"#595753"} labelColor={"white"}/></td>
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