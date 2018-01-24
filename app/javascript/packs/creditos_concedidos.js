import React from 'react';
import WebpackerReact from 'webpacker-react';
import ReporteAsesor from '../components/CreditosConcedidos/ReporteAsesor';
import CreditosTable from '../components/CreditosConcedidos/CreditosTable';
import ReporteAgencias from '../components/CreditosConcedidos/ReporteAgencias';
import ReporteGruposCredito from '../components/CreditosConcedidos/ReporteGruposCredito';
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

class CreditosConcedidos extends React.Component{

  constructor(props){
    super(props);
    this.state = {
      datosAsesor: [],
      datosAgencias: [],
      datosGrupoCredito: [],
      open: false
    };
    this.showAsesor = this.showAsesor.bind(this);
    this.showAgencias = this.showAgencias.bind(this);
    this.showGruposCredito = this.showGruposCredito.bind(this);
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
          diaFin: this.props.diaFin
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

  showAgencias(data){
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
          diaFin: this.props.diaFin

        }
      },
      headers: {
        'X-CSRF-TOKEN': this.props.authenticity_token
      }
    }).then(data => {
      this.setState({
        datosAgencias: data
      });
      this.SnackhandleClick();
      console.log(data);
    }).catch(err => {
      console.log(err)
    });

  }

  showGruposCredito(data){
    reqwest({
      url: this.props.url,
      method: 'POST',
      data: {
        consulta_detalles_asesor: {
          validation: 'si'
        },
        asesor: {
          grupo_credito: data,
          diaInicio: this.props.diaInicio,
          diaFin: this.props.diaFin
        }
      },
      headers: {
        'X-CSRF-TOKEN': this.props.authenticity_token
      }
    }).then(data => {
      this.setState({
        datosGrupoCredito: data
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
          <h4 style={{color: muiTheme.palette.accent1Color}}>Eficiencia de cartera por asesores</h4>
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
    } else if(this.props.tipoReporte === "agencia"){
      return(
        <div>
          <div>
            <h4 style={{color: muiTheme.palette.accent1Color}}>Eficiencia de cartera por agencias</h4>
            <ReporteAgencias data={ this.props.data } onClick={ this.showAgencias }/>
          </div>
          <div>
            <CreditosTable data={ this.state.datosAgencias }/>
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
            <h4 style={{color: muiTheme.palette.accent1Color}}>Eficiencia de cartera por grupos de credito</h4>
            <ReporteGruposCredito data={ this.props.data } onClick={ this.showGruposCredito }/>
          </div>
          <div>
            <CreditosTable data={ this.state.datosGrupoCredito }/>
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

WebpackerReact.setup({CreditosConcedidos});