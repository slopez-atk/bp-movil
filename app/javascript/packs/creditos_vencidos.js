import React from 'react';
import WebpackerReact from 'webpacker-react';
import ReporteAsesor from '../components/CreditosVencidos/ReporteAsesor';
import CreditosTable from '../components/CreditosVencidos/CreditosTable';
import ReporteAgencias from '../components/CreditosVencidos/ReporteAgencias';
import reqwest from 'reqwest';

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

class CreditosVencidos extends React.Component{

  constructor(props){
    super(props);
    this.state = {
      datosAsesor: [],
      datosSucursales: [],
      open: false
    };
    this.showAsesor = this.showAsesor.bind(this);
    this.showSucursales = this.showSucursales.bind(this);
  }

  showAsesor(data){
    // this.setState({datosAsesor: data});
    reqwest({
      url: this.props.url,
      method: 'POST',
      data: {
        consulta_detalles_asesor: {
          validation: 'si'
        },
        asesor: {
          nombre: data,
          diaInicio: this.props.diaInicio,
          diaFin: this.props.diaFin,
          fecha: this.props.fecha,
        }
      },
      headers: {
        'X-CSRF-TOKEN': this.props.authenticity_token
      }
    }).then(data => {
      this.setState({
        datosAsesor: data
      });
      this.SnackhandleClick();
      console.log(data);
    }).catch(err => {
      console.log(err)
    });

  }

  showSucursales(data){
    reqwest({
      url: this.props.url,
      method: 'POST',
      data: {
        consulta_detalles_asesor: {
          validation: 'si'
        },
        asesor: {
          sucursal: data,
          diaInicio: this.props.diaInicio,
          diaFin: this.props.diaFin,
          fecha: this.props.fecha,
        }
      },
      headers: {
        'X-CSRF-TOKEN': this.props.authenticity_token
      }
    }).then(data => {
      this.setState({
        datosSucursales: data
      });
      this.SnackhandleClick();
      console.log(data);
    }).catch(err => {
      console.log(err)
    });

  }

  SnackhandleClick = () => {
    this.setState({
      open: true,
    });
  };

  SnackhandleRequestClose = () => {
    this.setState({
      open: false,
    });
  };

  renderTables(){
    if( this.props.tipoReporte === "asesor"){
      return(
        <div>
          <h4 style={{color: muiTheme.palette.accent1Color}}>Consulta de créditos vencidos por asesores</h4>
          <div>
            <ReporteAsesor data={ this.props.data } onClick={ this.showAsesor }/>
          </div>
          <div>
            <CreditosTable data={ this.state.datosAsesor }/>
          </div>
          <div>
            <Snackbar
              open={this.state.open}
              message="Datos cargados"
              autoHideDuration={4000}
              onRequestClose={this.SnackhandleRequestClose}/>
          </div>
        </div>
      );
    } else {
      return(
        <div>
          <div>
            <h4 style={{color: muiTheme.palette.accent1Color}}>Consulta de créditos vencidos por agencia</h4>
            <ReporteAgencias data={ this.props.data } onClick={ this.showSucursales }/>
          </div>
          <div>
            <CreditosTable data={ this.state.datosSucursales }/>
          </div>
          <div>
            <Snackbar
              open={this.state.open}
              message="Datos cargados"
              autoHideDuration={4000}
              onRequestClose={this.SnackhandleRequestClose}/>
          </div>
        </div>
      );
    }
  }

  render(){
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <div>
          { this.renderTables() }
        </div>
      </MuiThemeProvider>
    );
  }
}

WebpackerReact.setup({CreditosVencidos});