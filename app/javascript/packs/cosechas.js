import React from 'react';
import WebpackerReact from 'webpacker-react';

// Material Ui
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import Snackbar from 'material-ui/Snackbar';
import TablaCoshechas from "../components/Cosechas/TablaCoshechas";
import TablaCreditos from "../components/Cosechas/TablaCreditos";

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


class Cosechas extends React.Component{
  constructor(props){
    super(props)
    this.state = {
      open: false,
      credits: []
    };
    this.showCredits = this.showCredits.bind(this);
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

  showCredits(yearKey, monthKey){
    this.setState({
      credits: this.props.datos[yearKey][monthKey]
    })
    this.SnackhandleClick();
  }



  render(){
    let datos = this.props.datos;
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <div>
          <h5 style={{color: muiTheme.palette.primary1Color}}>Cosechas</h5>
          <TablaCoshechas cantidades={ this.props.cantidades } saldos={ this.props.saldos } onClick={ this.showCredits }/>
          <TablaCreditos datos={ this.state.credits }/>
          <div>
            <Snackbar
              open={this.state.open}
              message="Datos cargados"
              autoHideDuration={4000}
              onRequestClose={this.SnackhandleRequestClose}/>
          </div>
        </div>
      </MuiThemeProvider>
    );
  }

}
WebpackerReact.setup({Cosechas});