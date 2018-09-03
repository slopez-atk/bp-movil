import React from 'react';
import WebpackerReact from 'webpacker-react';
import IndicadoresFinancieros from '../../components/Agencias/IndicadoresFinancieros/IndicadoresFinancieros';
import Graficas from '../../components/Agencias/IndicadoresFinancieros/Graficas';

//Material ui
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import Dialog from 'material-ui/Dialog';
import FlatButton from 'material-ui/FlatButton';

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

const customContentStyle = {
  width: '100%',
  maxWidth: 'none',
};

class IndicadoresParent extends React.Component{
  constructor(props){
    super(props);
    this.state = {
      dataGraphic: [],
      titulo: '',
      open: false
    };
    this.setDataGraphic = this.setDataGraphic.bind(this);
  }

  handleOpen = () => {
    this.setState({open: true});
  };

  handleClose = () => {
    this.setState({open: false});
  };

  setDataGraphic(data, titulo){
    this.setState({
      dataGraphic: data,
      titulo: titulo
    });
    this.handleOpen();
  }


  render(){
    const actions = [
      <FlatButton
        label="Cerrar Ventana"
        primary={true}
        onClick={this.handleClose}
      />,
    ];
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <div>
          <h4 style={{color: muiTheme.palette.accent1Color}} className="top-space">Indicadores Financieros</h4>

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
          patrimonio={this.props.patrimonio}
          onClick={this.setDataGraphic}
          agencia={this.props.agencia}
          utilidades={this.props.utilidades}/>


          <Dialog
            title={this.state.titulo}
            actions={actions}
            modal={true}
            contentStyle={customContentStyle}
            open={this.state.open}
            autoScrollBodyContent={true}>

            <Graficas data={this.state.dataGraphic} titulo={this.state.titulo}/>

          </Dialog>

        </div>
      </MuiThemeProvider>
    );
  }
}

WebpackerReact.setup({IndicadoresParent});