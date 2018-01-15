import React from 'react';
import WebpackerReact from 'webpacker-react';
import IndicadoresFinancieros from '../../components/Agencias/IndicadoresFinancieros/IndicadoresFinancieros';

//Material ui
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import Snackbar from 'material-ui/Snackbar';

const muiTheme = getMuiTheme({
  drawer: {
    color: '#FDD835'
  },
  appBar: {
    color: '#2E3092'
  },
  palette: {
    primary1Color: "#3F51B5",
    accent1Color: "#FFC107",
  }
});

class IndicadoresParent extends React.Component{
  constructor(props){
    super(props);
  }


  render(){
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <div>
          <IndicadoresFinancieros activos={this.props.activos}
          fondos= {this.props.fondos}
          recerva_prestamo={this.props.recerva_prestamo}
          pasivos={this.props.pasivos}
          obligaciones={this.props.obligaciones}
          deposito_vista={this.props.deposito_vista}
          dpf_cesantia={this.props.dpf_cesantia}
          certificados_aportacion={this.props.certificados_aportacion}
          ingresos_totales={this.props.ingresos_totales}
          intereses_descuentos={this.props.intereses_descuentos}
          operaciones_interfinancieras={ this.props.operaciones_interfinancieras}
          intereses_inversiones={this.props.intereses_inversiones}
          intereses_cartera_credito={this.props.intereses_cartera_credito}
          ingresos_servicio={this.props.ingresos_servicio}
          otros_ingresos={this.props.otros_ingresos}
          gastos_totales={this.props.gastos_totales}
          gastos_financieros={this.props.gastos_financieros}
          intereses_causados={this.props.intereses_causados}
          gastos_provision={this.props.gastos_provision}
          gastos_operacionales={this.props.gastos_operacionales}
          gastos_personal={this.props.gastos_personal}
          caja_bancos={this.props.caja_bancos}
          cartera_bruta={this.props.cartera_bruta}
          cartera_bruta_microcredito={this.props.cartera_bruta_microcredito}
          cartera_riesgo={this.props.cartera_riesgo}
          patrimonio={this.props.patrimonio}/>
        </div>
      </MuiThemeProvider>
    );
  }
}

WebpackerReact.setup({IndicadoresParent});